require 'net/http'
require 'nokogiri'

class ReservesController < ApplicationController
  
  def index
    editor = Editor.find_by_sunetid(current_user)
    @my_reserves = editor.nil? ? [] : editor.reserves
  end
  
  def all_courses
    render :layout => false if request.xhr?
  end

  def all_courses_response
    items = []
    CourseReserves::Application.config.courses.all_courses.each do |course|
      items << [course[:cid], "<a href='/reserves/new?cid=#{course[:cid]}&instructors=#{course[:instructors].map{|i| i[:sunet]}.compact.join(",")}'>#{course[:title]} [section #{course[:sid]}]</a>", course[:instructors].map{|i| i[:name]}.compact.join(", ")]
    end
    render :json => {"aaData" => items}.to_json, :layout => false
  end
  
  def new
    reserve = Reserve.find_all_by_cid(params[:cid])
    #unless reserve.blank?
      reserve.each do |res|
        editors = res.editors.map{|e| e[:sunetid] }.compact
        if CourseReserves::Application.config.super_sunets.include?(current_user) or params[:instructors].split(",").map{|i| editors.include?(i.strip) }.include?(true)
          redirect_to edit_reserve_path(res[:id]) and return
        end
      end
    #else
      courses = CourseReserves::Application.config.courses.find_by_class_id(params[:cid])
      instructors = courses.map{|c| c[:instructors].map{|i| i[:sunet] } }.flatten.compact.uniq 
      unless courses.blank?
        if !instructors.include?(current_user) and !CourseReserves::Application.config.super_sunets.include?(current_user)
          flash[:error] = "You are not the instructor for this course."
          redirect_to root_path
        end
        @course = params[:instructors].split(",").map{|i| CourseReserves::Application.config.courses.find_by_class_id_and_sunet(params[:cid], i.strip).first}.first
      end
    #end
  end

  
  def add_item
    respond_to do |format|
      format.js do
        params[:index] = 0
        if params[:sw]=='false'
          params[:item] = {}       
        elsif params[:sw]=='true'
          params[:item] = {} 
          ckey = params[:url].strip[/(\d+)$/]
          url = "http://searchworks.stanford.edu/view/#{ckey}.mobile?covers=false"
          doc = Nokogiri::XML(Net::HTTP.get(URI.parse(url)))
          title = doc.xpath("//full_title").text
          format = doc.xpath("//formats/format").map{|x| x.text }
          render :text => "alert('This does not appear to be a valid item in SearchWorks')" and return if title.blank?
          params[:item] = {:title => doc.xpath("//full_title").text, :ckey => ckey }
          params[:item].merge!(:loan_period=>"4 hours", :media=>"true") if format.include?("Video")
        end
      end
    end
  end
  
  def create
    if CourseReserves::Application.config.super_sunets.include?(current_user) or params[:reserve][:instructor_sunet_ids].split(",").map{|sunet| sunet.strip }.include?(current_user)
      # Will need to do something like this.  But we need a way to find the current term programatically
      # params[:reserve][:term] == "current_term" unless params[:reserve][:immediate] == "false"
      @reserve = Reserve.create(params[:reserve])
      @reserve.save! 
      send_course_reserve_request(@reserve) if params.has_key?(:send_request)
      redirect_to({ :controller => 'reserves', :action => 'edit', :id => @reserve[:id] }) 
    else
      flash[:error] = "You do not have permissions to create his course reserve list."
      redirect_to(root_path)
    end
  end
  
  def edit    
    reserve = Reserve.find(params[:id])
    if !CourseReserves::Application.config.super_sunets.include?(current_user) and !reserve.editors.map{|e| e[:sunetid] }.compact.include?(current_user)
      flash[:error] = "You do not have permission to edit this course reserve."
      redirect_to(root_path)
    end
    @reserve = reserve
  end
  
  def update
    reserve = Reserve.find(params[:id])
    # Will need to do something like this.  But we need a way to find the current term programatically
    # params[:reserve][:term] == "current_term" unless params[:reserve][:immediate] == "false"
    params[:reserve][:item_list] = [] unless params[:reserve].has_key?(:item_list)
    if params.has_key?(:send_request) and reserve.has_been_sent == true
      send_updated_course_reserve_request(reserve)
    elsif reserve.has_been_sent == false or reserve.has_been_sent.nil?
      send_course_reserve_request(reserve)
    else
      reserve.update_attributes(params[:reserve])
      #Reserve.update(params[:id], params[:reserve])
    end
    redirect_to({ :controller => 'reserves', :action => 'edit', :id => params[:id] }) 
  end
  
  def show
    @reserve = Reserve.find(params[:id])
  end
  
  
  protected
  
  def send_course_reserve_request(reserve)
    #send email here
    reserve.update_attributes(:has_been_sent => true)
  end
  
  def send_updated_reserve_request(reserve)
    old_reserve = reserve.dup
    reserve.update_attributes(params[:reserve].merge(:has_been_sent => true))
    email_body = process_diff(old_reserve,reserve)
    #send email here
  end
  
  def process_diff(old_reserve,new_reserve)
    total_reserves = []
    item_text = ""
    new_reserve.item_list.each_with_index do |new_item, index|
      total_reserves << new_item
      unless old_reserve.item_list[index] == new_item or old_reserve.item_list.include?(new_item)
        #total_reserves << old_reserve.item_list[index]
        # we should assume this is the same item at that point.
        if old_reserve.item_list[index] and old_reserve.item_list[index][:ckey] == new_item[:ckey] and old_reserve.item_list[index][:title] == new_item[:title]
          total_reserves << old_reserve.item_list[index]
          item_text << "Changed item\n"
          new_item.each do |key,value|
            if old_reserve.item_list[index][key] == value
              # maybe to a key translate here for human consumption
              item_text << "#{key}: #{value}\n"
            else
              item_text << "#{key}: #{value} (was: #{old_reserve.item_list[index][key]})\n"
            end
          end
        elsif !new_item[:ckey].blank? and !old_reserve.item_list.map{|old_r| old_r if old_r[:ckey] == new_item[:ckey]}.compact.blank?
          old_item = old_reserve.item_list.map{|old_r| old_r if old_r[:ckey] == new_item[:ckey]}.compact.first
          total_reserves << old_item
          item_text << "Changed item\n"
          new_item.each do |key,value|
            if old_item[key] == value
              # maybe to a key translate here for human consumption
              item_text << "#{key}: #{value}\n"
            else
              item_text << "#{key}: #{value} (was: #{old_item[key]})\n"
            end
          end
        else
          item_text << "New item\n"
          new_item.each do |key,value|
            # maybe to a key translate here for human consumption
            item_text << "#{key}: #{value}\n"
          end
        end
      end
    end
    (old_reserve.item_list - total_reserves).each do |delete_item|
      item_text << "Deleted item\n"
      delete_item.each do |key,value|
        # maybe to a key translate here for human consumption
        item_text << "#{key}: #{value}\n"
      end
    end
    item_text
  end
  
end
