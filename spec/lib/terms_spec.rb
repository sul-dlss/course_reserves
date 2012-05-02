require 'spec_helper'
require 'terms'
describe "Terms" do
  include Terms
  describe "current_term_hash" do
    it "should return the appropriate term in the middle of a term" do
      term = current_term_hash(Date.new(2017, 7, 10))
      term[:term].should == "Summer 2017"
    end
    it "should return the appropriate term on the last day of the quarter" do
      term = current_term_hash(Date.new(2018, 3, 23))
      term[:term].should == "Winter 2018"
    end
    it "should return the appropriate term on the first day of the quarter" do
      term = current_term_hash(Date.new(2018, 3, 24))
      term[:term].should == "Spring 2018"
    end
  end
  describe "future terms" do
    it "should return 2 terms" do
      future_terms.length.should == 2
    end
    it "should return the two terms after a particular term" do
      ft = future_terms("Winter 2016")
      ft.length.should == 2
      ft.include?("Spring 2016").should be_true
      ft.include?("Summer 2016").should be_true
    end
    it "should handle future terms that split the academic calendar" do
      ft = future_terms("Spring 2016")
      ft.length.should == 2
      ft.include?("Summer 2016").should be_true
      ft.include?("Fall 2016").should be_true
    end
    it "should be able to handle when we are at the end of the academic calendar" do
      ft = future_terms("Summer 2016")
      ft.length.should == 2
      ft.include?("Fall 2016").should be_true
      ft.include?("Winter 2017").should be_true
    end
    it "should return 1 term when we are at the end of the list" do
      future_terms("Spring 2020").should == ["Summer 2020"]
    end
  end
end
