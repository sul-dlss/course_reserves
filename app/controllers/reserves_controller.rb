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
      items << [course[:cid], "<a href='/reserves/new?cid=#{course[:cid]}&sid=#{course[:sid]}&term=#{course[:term]}'>#{course[:title]} [section #{course[:sid]}]</a>", course[:instructors].map{|i| i[:name]}.compact.join(", ")]
    end
    render :json => {"aaData" => items}.to_json, :layout => false
  end
  
  def new
    reserve = Reserve.find_by_cid_and_sid_and_term(params[:cid], params[:sid], params[:term])
    unless reserve.nil?  
      if CourseReserves::Application.config.super_sunets.include?(current_user) or reserve.editors.map{|e| e[:sunetid] }.compact.include?(current_user)
        redirect_to edit_reserve_path(reserve[:id]) 
      end
    else
      # Do we need to find my term too?  There isn't a finder for that yet.
      course = CourseReserves::Application.config.courses.find_by_class_id_and_section(params[:cid], params[:sid]).first
      if !course[:instructors].map{|i| i[:sunet] }.compact.include?(current_user) and !CourseReserves::Application.config.super_sunets.include?(current_user)
        flash[:error] = "You are not the instructor for this course."
        redirect_to root_path
      end
      @course = course
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
          params[:item] = {:title => doc.xpath("//full_title").text, :ckey => ckey }
        end
      end
    end
  end
  
  def create     
    @reserve = Reserve.create(params[:reserve])
    @reserve.save! 
    redirect_to({ :controller => 'reserves', :action => 'edit', :id => @reserve[:id] }) 
  end
  
  def edit    
    @reserve = Reserve.find(params[:id])
  end
  
  def update    
    params[:reserve][:item_list] = [] unless params[:reserve].has_key?(:item_list)
    Reserve.update(params[:id], params[:reserve])
    
    redirect_to({ :controller => 'reserves', :action => 'edit', :id => params[:id] }) 
  end
  
  def show
    @reserve = Reserve.find(params[:id])
  end
  
end
