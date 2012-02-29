require 'net/http'
require 'nokogiri'

class ReservesController < ApplicationController
  
  def index
    #@my_reserves = Editor.find_by_sunetid(request.env['WEBAUTH_USER']).reserves
  end
  
  def all_courses
    @courses = CourseReserves::Application.config.courses.all_courses
    render :layout => false if request.xhr?
  end

  def all_courses_response
    text = '{ "aaData": ['
    items = []
    CourseReserves::Application.config.courses.all_courses.each do |course|
      item = '[ "' << course[:cid] << '", "' << course[:title].gsub('"', "&#34").gsub("'","&#39") << '", "' << course[:instructors].map{|i| i[:name]}.compact.join(", ") << '" ]'
      items << item
    end
    text << items.join(", ")
    text << ' ] }'
    render :text => text, :layout => false
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
