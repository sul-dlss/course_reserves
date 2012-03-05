class Reserve < ActiveRecord::Base
  
  before_update :process_sunet_ids 

  has_and_belongs_to_many :editors
  
  validates :library, :presence => true # need to make sure (select library) isn't selected
  # taking immediate validation out for now.  Enforced in the UI.
  #validates :immediate, :presence => true 
  validates :contact_name, :presence => true
  validates :contact_phone, :presence => true
  validates :contact_email, :presence => true
  
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
