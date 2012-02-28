class ReservesController < ApplicationController
  
  def index
    #@my_reserves = Editor.find_by_sunetid(request.env['WEBAUTH_USER']).reserves
  end
  
  def new
  end
  
  def add_item
    respond_to do |format|
      format.js do
        if params[:sw]=='false'
          params[:item] = {}
          params[:index] = 0
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
