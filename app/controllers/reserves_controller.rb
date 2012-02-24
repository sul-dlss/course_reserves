class ReservesController < ApplicationController
  
  def index
    #@my_reserves = Editor.find_by_sunetid(request.env['WEBAUTH_USER']).reserves
  end
  
  def new
  end
  
  def create     
    @reserve = Reserve.create(params[:reserve])
    @reserve.save!
  end
  
  def edit    
    @reserve = Reserve.find(params[:id])    
  end
  
  def update    
    Reserve.update(params[:reserve][:id], params[:reserve])
    redirect_to edit_reserve(params[:reserve][:id])
  end
  
  def show
    @reserve = Reserve.find(params[:id])
  end
  
end
