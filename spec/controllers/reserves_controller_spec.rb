require 'spec_helper'

describe ReservesController do
  describe "new" do
    it "should redirect to an existing course list if it exists and the current user is an editor" do
      r = Reserve.create({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet"})
      r.save!
      controller.stub(:current_user).and_return("user_sunet")
      get :new, {:cid => "CID1", :sid => "01"}
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should redirect to an existing course list if it exists and the current user is a super user" do
      r = Reserve.create({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet"})
      r.save!
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      r.editors.map{|e| e[:sunetid] }.include?("rwmantov").should be_false
      get :new, {:cid => "CID1", :sid => "01"}
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
  end
  
  describe "update" do
    it "should clear out the item_list if no item_list params is in the URL" do
      r = Reserve.create({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :item_list => [{:ckey => "item1"}]})
      r.save!
      r.item_list.length.should == 1
      get :update, {:id => r[:id], :reserve => {:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet"}}
      response.should redirect_to(edit_reserve_path(r[:id]))
      Reserve.find(r[:id]).item_list.should be_blank
    end
  end
  
  describe "all_courses" do
    it "does something" do
      get :all_courses_response
      body = JSON.parse(response.body)
      body.keys.length.should == 1
      body.has_key?("aaData").should be_true
      body["aaData"].length.should == 5
      body["aaData"].each do |item|
        item.length.should == 3
      end
    end
  end
end
