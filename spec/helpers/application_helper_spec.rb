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
  
  describe "terms" do
    # describe "current_term" do
    #   it "should do something" do
    #     current_term.should == ""
    #   end
    # end
    describe "future terms" do
      it "should return 2 terms" do
        future_terms.length.should == 2
      end
      it "should return the two terms after a particular term" do
        ft = future_terms("Fall")
        ft.length.should == 2
        ft.include?("Winter").should be_true
        ft.include?("Spring").should be_true
      end
      it "should handle future terms that split the academic calendar" do
        ft = future_terms("Spring")
        ft.length.should == 2
        ft.include?("Summer").should be_true
        ft.include?("Fall").should be_true
      end
      it "should be able to handle when we are at the end of the academic calendar" do
        ft = future_terms("Summer")
        ft.length.should == 2
        ft.include?("Fall").should be_true
        ft.include?("Winter").should be_true
      end
    end
  end
end