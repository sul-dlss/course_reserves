class Reserve < ActiveRecord::Base
  before_save :process_sunet_ids

  has_and_belongs_to_many :editors

  # maybe turn these validations on during initial import?
  # validates :library, :presence => true # need to make sure (select library) isn't selected
  # validates :contact_name, :presence => true
  # validates :contact_phone, :presence => true
  # validates :contact_email, :presence => true

  serialize :item_list, Array
  serialize :sent_item_list, Array

  def course
    @course ||= CourseWorkCourses.instance.find_by_compound_key(compound_key).first
  end

  private

  def process_sunet_ids
    editors = []

    if self.instructor_sunet_ids.present?
      self.instructor_sunet_ids.split(/,/).map { |i| i.strip }.each do |s|
        ed = Editor.find_or_create_by sunetid: s
        ed.save!
        editors << ed
      end
    end

    if self.editor_sunet_ids.present?
      self.editor_sunet_ids.split(/,/).map { |i| i.strip }.each do |s|
        ed = Editor.find_or_create_by sunetid: s
        ed.save!
        editors << ed
      end
    end

    self.editors = editors if editors.present?
  end
end
