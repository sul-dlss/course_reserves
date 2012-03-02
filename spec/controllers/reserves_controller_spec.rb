require 'spec_helper'

describe ReservesController do
  describe "new" do
    it "should redirect to an existing course list if it exists and the current user is an editor" do
      r = Reserve.create({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :term => "Winter 2012"})
      r.save!
      controller.stub(:current_user).and_return("user_sunet")
      get :new, {:cid => "CID1", :sid => "01", :term => "Winter 2012"}
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should redirect to an existing course list if it exists and the current user is a super user" do
      r = Reserve.create({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :term => "Winter 2012"})
      r.save!
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      r.editors.map{|e| e[:sunetid] }.include?("rwmantov").should be_false
      get :new, {:cid => "CID1", :sid => "01", :term => "Winter 2012"}
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should let you create a new course if you are a super user" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      get :new, {:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012"}
      response.should be_success  
    end
    it "should let you create a new course if you are the professor" do
      controller.stub(:current_user).and_return("123")
      get :new, {:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012"}
      response.should be_success
    end
    it "should not let you create a course that you don't have permisisons to" do
      get :new, {:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012"}
      response.should redirect_to(root_path)
      flash[:error].should == "You are not the instructor for this course."
    end
  end
  
  describe "create" do
    it "should allow you to create an item if you are the instructor" do
      controller.stub(:current_user).and_return("user_sunet")
      post :create, :reserve => {:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"}
      r = assigns(:reserve)
      r.cid.should == "EDUC-237X"
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should allow you to create an item if you are a super sunet" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      post :create, :reserve => {:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"}
      r = assigns(:reserve)
      r.cid.should == "EDUC-237X"
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should redirecto the home page if the user does not have access to create this reserve list" do
      controller.stub(:current_user).and_return("cannot_edit")
      post :create, :reserve => {:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"}
      response.should redirect_to(root_path)
      flash[:error].should == "You do not have permissions to create his course reserve list."
    end
  end
  
  describe "edit" do
    it "should allow you to get to the edit screen if you are an editor if the item" do
      controller.stub(:current_user).and_return("user_sunet")
      r = Reserve.create({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"})
      r.save!
      get :edit, :id => r[:id]
      response.should be_success
      assigns(:reserve).should == r
    end
    it "should allow you to get to the edit screen if you are an super sunet" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      r = Reserve.create({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"})
      r.save!
      get :edit, :id => r[:id]
      response.should be_success
      assigns(:reserve).should == r
    end
    it "should redirect if the user does not have permissions to edit the reserve" do
      controller.stub(:current_user).and_return("some_user")
      r = Reserve.create({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"})
      r.save!
      get :edit, :id => r[:id]
      response.should redirect_to(root_path)
      flash[:error].should == "You do not have permission to edit this course reserve."
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
  
  describe "index" do
    it "should return reserves for a user when they have them" do
      r = Reserve.create({:cid=>"CID1", :sid => "SID1", :instructor_sunet_ids => "user_sunet"})
      r.save!
      controller.stub(:current_user).and_return("user_sunet")
      get :index
      response.should be_success
      my_reserves = assigns(:my_reserves)
      my_reserves.length.should == 1
      my_reserves.first.cid.should == "CID1"
      my_reserves.first.sid.should == "SID1"
    end
  end
  
  describe "all_courses" do
    it "should return parsable JSON" do
      get :all_courses_response
      response.should be_success
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
