class Editor < ActiveRecord::Base
  has_and_belongs_to_many :reserves
  validates :sunetid, presence: true
end
