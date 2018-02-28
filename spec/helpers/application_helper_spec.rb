require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#item_in_searchworks?" do
    it "returns true when we directly pass :sw throug the URL" do
      params[:sw] = "true"
      expect(item_in_searchworks?({})).to be_truthy
    end

    it "returns true if an item has a ckey" do
      expect(item_in_searchworks?({"ckey" => "54321"})).to be_truthy
    end

    it "returns false when neither the params nor the item indicate it is a SearchWorks item" do
      expect(item_in_searchworks?({:comment=>"hello", :copies=>"3", :loan_period => "1 day"})).to be_falsey
    end
  end
end
