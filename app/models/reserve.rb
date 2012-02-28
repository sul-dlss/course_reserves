class Reserve < ActiveRecord::Base
  
  before_create :process_sunet_ids 

  has_and_belongs_to_many :editors
  
  serialize :item_list, Array
  
  private
  
  def process_sunet_ids
    
    editors = []
    
    unless self.instructor_sunet_ids.blank?
      self.instructor_sunet_ids.split(/,/).map{|i| i.strip}.each do |s|
        ed = Editor.find_or_create_by_sunetid(s)
        ed.save!
        editors << ed
      end
    end
    
    unless self.editor_sunet_ids.blank?
      self.editor_sunet_ids.split(/,/).map{|i| i.strip}.each do |s|
        ed = Editor.find_or_create_by_sunetid(s)
        ed.save!
        editors << ed
      end
    end

    self.editors = editors unless editors.blank?
    
  end
  

end
