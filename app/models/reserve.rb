class Reserve < ActiveRecord::Base

  serialize :item_list, Array

end
