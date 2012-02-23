class Reserve < ActiveRecord::Base

  has_and_belongs_to_many :editors
  
  serialize :item_list, Array
  
  #def self.editors
 
    
 
  #end
  

end
