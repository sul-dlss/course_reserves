require 'net/http'
require 'nokogiri'

class ReservesController < ApplicationController
  
  def index
    editor = Editor.find_by_sunetid(current_user)
    @my_reserves = editor.nil? ? [] : editor.reserves
  end
  
  def all_courses
    @courses = CourseReserves::Application.config.courses.all_courses
    render :layout => false if request.xhr?
  end

  def all_courses_response
    items = []
    CourseReserves::Application.config.courses.all_courses.each do |course|
      items << [course[:cid], "<a href='#{new_reserve_path(:cid=>course[:cid], :desc=>course[:title], :sid=>course[:sid], :instructor_sunet_ids=>course[:instructors].map{|i| i[:sunet] }.compact.join(", "), :instructor_names => course[:instructors].map{|i| i[:name] }.compact.join(", "))}'>#{course[:title]} [section #{course[:sid]}]</a>", course[:instructors].map{|i| i[:name]}.compact.join(", ")]
    end
    render :json => {"aaData" => items}.to_json, :layout => false
  end
  
  def new
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
