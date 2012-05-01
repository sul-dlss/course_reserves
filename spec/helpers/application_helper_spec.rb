require 'spec_helper'

describe ApplicationHelper do
  describe "item_in_searchworks?" do
    it "should return true when we directly pass :sw throug the URL" do
      params[:sw] = "true"
      item_in_searchworks?({}).should be_true
    end
    it "should return true if an item has a ckey" do
      item_in_searchworks?({"ckey" => "54321"}).should be_true
    end
    it "should return false when neither the params nor the item indicate it is a SearchWorks item" do
      item_in_searchworks?({:comment=>"hello", :copies=>"3", :loan_period => "1 day"}).should be_false
    end
  end
end