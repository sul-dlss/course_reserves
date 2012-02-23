class Reserve < ActiveRecord::Base
  
  before_create :process_sunet_ids 

  has_and_belongs_to_many :editors
  
  serialize :item_list, Array
  
  private
  
  def process_sunet_ids
    
    editors = []
    unless self.editor_sunet_ids.blank?
      self.editor_sunet_ids.split(/,/).map{|i| i.strip}.each do |s|
        editors << Editor.find_or_create_by_sunetid(s) 
      end
    end

    self.editors = editors unless editors.blank?
    
  end
  

end
