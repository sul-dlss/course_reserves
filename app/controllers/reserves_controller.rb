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
      cl = course[:cross_listings].blank? ? "" : "(#{course[:cross_listings]})"
      items << [course[:cid], "<a href='/reserves/new?comp_key=#{course[:comp_key]}'>#{course[:title]}</a> #{cl}", course[:instructors].map{|i| i[:name]}.compact.join(", ")]
    end
    render :json => {"aaData" => items}.to_json, :layout => false
  end
  
  def new
    reserve = Reserve.find_by_compound_key(params[:comp_key])
    unless reserve.nil?
      editors = reserve.editors.map{|e| e[:sunetid] }.compact
      if CourseReserves::Application.config.super_sunets.include?(current_user) or editors.include?(current_user)
        redirect_to edit_reserve_path(reserve[:id]) and return
      end
    else
      course = CourseReserves::Application.config.courses.find_by_compound_key(params[:comp_key]).first
      unless course.blank?
        instructors = course[:instructors].map{|i| i[:sunet] }.compact.uniq
        if !instructors.include?(current_user) and !CourseReserves::Application.config.super_sunets.include?(current_user)
          flash[:error] = "You are not the instructor for this course."
          redirect_to root_path
        end
        @course = course
      end
    end
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
      params[:reserve][:term] = CourseReserves::Application.config.current_term if params[:reserve][:immediate] == "true"
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
    params[:reserve][:term] = CourseReserves::Application.config.current_term if params[:reserve][:immediate] == "true"
    params[:reserve][:item_list] = [] unless params[:reserve].has_key?(:item_list)
    if params.has_key?(:send_request) and reserve.has_been_sent == true
      send_updated_reserve_request(reserve)
    elsif params.has_key?(:send_request) and (reserve.has_been_sent == false or reserve.has_been_sent.nil?)
      send_course_reserve_request(reserve)
    else
      reserve.update_attributes(params[:reserve])
    end
    redirect_to({ :controller => 'reserves', :action => 'edit', :id => params[:id] }) 
  end
  
  def clone
    original_reserve = Reserve.find(params[:id])
    if original_reserve.editors.map{|e| e[:sunetid]}.include?(current_user) or CourseReserves::Application.config.super_sunets.include?(current_user)
      reserve = original_reserve.dup
      reserve.has_been_sent = nil
      reserve.disabled = nil
      reserve.sent_date = nil
      reserve.term = params[:term]
      reserve.immediate = nil
      reserve.save!
      redirect_to(edit_reserve_path(reserve[:id]))
    else
      flash[:error] = "You do not have permission to clone this course list."
      redirect_to(root_path)
    end
  end
  
  def show
    @reserve = Reserve.find(params[:id])
  end
  
  
  protected
  
  def send_course_reserve_request(reserve)
    if !request.env["HTTP_HOST"].nil? and request.env["HTTP_HOST"].include?("reserves") and !request.env["HTTP_HOST"].include?("-test")
      address = CourseReserves::Application.config.email_mapping[reserve.library]
    else
      address = "jkeck@stanford.edu"
    end
    
    ReserveMail.first_request(reserve, address).deliver
    reserve.update_attributes(params[:reserve].merge(:has_been_sent => true, :sent_item_list => reserve.item_list, :sent_date => DateTime.now.strftime("%m-%d-%Y %I:%M%p").gsub("AM","am").gsub("PM","pm")))
  end
  
  def send_updated_reserve_request(reserve)
    old_reserve = reserve.dup
    reserve.update_attributes(params[:reserve].merge(:has_been_sent => true, :sent_item_list => reserve.item_list, :sent_date => DateTime.now.strftime("%m-%d-%Y %I:%M%p").gsub("AM","am").gsub("PM","pm")))
    diff_text = process_diff(old_reserve.sent_item_list, reserve.item_list)
    
    if !request.env["HTTP_HOST"].nil? and request.env["HTTP_HOST"].include?("reserves") and !request.env["HTTP_HOST"].include?("-test")
      address = CourseReserves::Application.config.email_mapping[reserve.library]
    else
      address = "jkeck@stanford.edu"
    end
    ReserveMail.updated_request(reserve, address, diff_text).deliver
  end
  
  def process_diff(old_reserve,new_reserve)
    total_reserves = []
    item_text = ""
    new_reserve.each_with_index do |new_item, index|
      total_reserves << new_item
      unless old_reserve[index] == new_item or old_reserve.include?(new_item)
        # we should assume this is the same item at that point.
        if old_reserve[index] and old_reserve[index][:ckey] == new_item[:ckey] and !new_item[:ckey].blank? and old_reserve[index][:title] == new_item[:title]
          total_reserves << old_reserve[index]
          item_text << "***EDITED ITEM***\n"
          new_item.each do |key,value|
            if old_reserve[index][key] == value
              # maybe to a key translate here for human consumption
              item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)}\n" unless value.blank? and old_reserve[index][key].blank?
            else
              item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)} (was: #{translate_value_for_email(key, old_reserve[index][key])})\n"
            end
          end
          item_text << "====================================\n"
        elsif !new_item[:ckey].blank? and !old_reserve.map{|old_r| old_r if old_r[:ckey] == new_item[:ckey]}.compact.blank?
          old_item = old_reserve.map{|old_r| old_r if old_r[:ckey] == new_item[:ckey]}.compact.first
          total_reserves << old_item
          item_text << "***EDITED ITEM***\n"
          new_item.each do |key,value|
            if old_item[key] == value
              # maybe to a key translate here for human consumption
              item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)}\n" unless value.blank? and old_item[key].blank?
            else
              item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)} (was: #{translate_value_for_email(key, old_item[key])})\n"
            end
          end
          item_text << "====================================\n"
        else
          item_text << "***ADDED ITEM***\n"
          new_item.each do |key,value|
            # maybe to a key translate here for human consumption
            item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)}\n" unless value.blank?
          end
          item_text << "====================================\n"
        end
      end
    end
    (old_reserve - total_reserves).each do |delete_item|
      item_text << "***DELETED ITEM***\n"
      delete_item.each do |key,value|
        # maybe to a key translate here for human consumption
        item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)}\n" unless value.blank?
      end
      item_text << "====================================\n"
    end
    item_text
  end
  
  def translate_key_for_email(key)
    return translations[key.to_s]
  end
  
  def translations
    {"title" => "Title: ",
     "ckey" => "CKey: ",
     "comment" => "Comment: ",
     "loan_period" => "Circ rule: ",
     "copies" => "Copies: ",
     "purchase" => "Purchase this item? ",
     "personal" => "Is there a personal copy available? "}    
  end
  
  def translate_value_for_email(key, value)
    if value == "true"
      return "yes"
    elsif key == "loan_period"
      CourseReserves::Application.config.loan_periods.key(value)
    elsif value.blank?
      return "blank"
    else
      return value
    end
  end
  
end
