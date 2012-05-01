require 'spec_helper'
require 'terms'
describe ReservesController do
  include Terms
  before(:each) do
    @reserve_params = {:library => "Green", :immediate=>"true", :contact_name => "John Doe", :contact_phone=>"(555)555-5555", :contact_email=>"jdoe@example.com"}
  end
  describe "new" do
    it "should redirect to an existing course list if it exists and the current user is an editor" do
      r1 = Reserve.create(@reserve_params.merge({:cid => "CID1", :sid => "02", :compound_key => "CID1,another_sunet" , :instructor_sunet_ids => "another_sunet", :term => "Winter 2012"}))
      r1.save!
      r = Reserve.create(@reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet", :term => "Winter 2012"}))
      r.save!
      controller.stub(:current_user).and_return("user_sunet")
      get :new, {:comp_key => "CID1,user_sunet"}
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should redirect to an existing course list if it exists and the current user is a super user" do
      r = Reserve.create(@reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet", :term => "Winter 2012"}))
      r.save!
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      r.editors.map{|e| e[:sunetid] }.include?("rwmantov").should be_false
      get :new, {:comp_key => "CID1,user_sunet"}
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should let you create a new course if you are a super user" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      get :new, {:comp_key => "AFRICAAM-165E,EDUC-237X,ETHICSOC-165E,123,456"}
      response.should be_success  
      course = assigns(:course)
      course[:cid].should == "EDUC-237X"
      course[:title].should == "Residential Racial Segregation and the Education of African-American Youth"
      course[:instructors].map{|i| i[:sunet] }.include?("456").should be_true
    end
    it "should let you create a new course if you are the professor" do
      controller.stub(:current_user).and_return("123")
      get :new, {:comp_key => "AA-272C,123,456"}
      response.should be_success
      course = assigns(:course)
      course[:cid].should == "AA-272C"
      course[:instructors].map{|i| i[:sunet] }.include?("123").should be_true
    end
    it "should not let you create a course that you don't have permisisons to" do
      get :new, {:comp_key => "AA-272C,123,456"}
      response.should redirect_to(root_path)
      flash[:error].should == "You are not the instructor for this course."
    end
  end
  
  describe "create" do
    it "should allow you to create an item if you are the instructor" do
      controller.stub(:current_user).and_return("user_sunet")
      post :create, :reserve => @reserve_params.merge({:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"})
      r = assigns(:reserve)
      r.cid.should == "EDUC-237X"
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should allow you to create an item if you are a super sunet" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      post :create, :reserve => @reserve_params.merge({:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"})
      r = assigns(:reserve)
      r.cid.should == "EDUC-237X"
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should save the configured current term when immediate is selected" do
      controller.stub(:current_user).and_return("user_sunet")
      post :create, :reserve => @reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010"})
      r = assigns[:reserve]
      r.term.should == current_term
      response.should redirect_to(edit_reserve_path(r[:id]))
    end
    it "should redirecto the home page if the user does not have access to create this reserve list" do
      controller.stub(:current_user).and_return("cannot_edit")
      post :create, :reserve => @reserve_params.merge({:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"})
      response.should redirect_to(root_path)
      flash[:error].should == "You do not have permission to create this course reserve list."
    end
  end
  
  describe "edit" do
    it "should allow you to get to the edit screen if you are an editor if the item" do
      controller.stub(:current_user).and_return("user_sunet")
      r = Reserve.create(@reserve_params.merge({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"}))
      r.save!
      get :edit, :id => r[:id]
      response.should be_success
      assigns(:reserve).should == r
    end
    it "should allow you to get to the edit screen if you are an super sunet" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      r = Reserve.create(@reserve_params.merge({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"}))
      r.save!
      get :edit, :id => r[:id]
      response.should be_success
      assigns(:reserve).should == r
    end
    it "should redirect if the user does not have permissions to edit the reserve" do
      controller.stub(:current_user).and_return("some_user")
      r = Reserve.create(@reserve_params.merge({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"}))
      r.save!
      get :edit, :id => r[:id]
      response.should redirect_to(root_path)
      flash[:error].should == "You do not have permission to edit this course reserve list."
    end
  end
  
  describe "update" do
    it "should clear out the item_list if no item_list params is in the URL" do
      r = Reserve.create(@reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :item_list => [{:ckey => "item1"}]}))
      r.save!
      r.item_list.length.should == 1
      get :update, {:id => r[:id], :reserve => {:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet"}}
      response.should redirect_to(edit_reserve_path(r[:id]))
      Reserve.find(r[:id]).item_list.should be_blank
    end
    it "should not allow you to update a reserve w/ a term that already has a record in the database" do
      r1 = Reserve.create(@reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :term => "Spring 2012", :instructor_sunet_ids => "user_sunet"}))
      r2 = Reserve.create(@reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :term => "Summer 2012", :instructor_sunet_ids => "user_sunet"}))
      r1.save!
      r2.save!
      get :update, {:id => r2[:id], :reserve => {:cid => "CID1", :sid => "01", :term => "Spring 2012"}}
      response.should redirect_to(edit_reserve_path(r2[:id]))
      Reserve.find(r2[:id]).term.should == "Summer 2012"
      flash[:error].should == "Course reserve list already exists for this course and term. The term has not been saved."
    end
    it "should save the configured current term when immediate is selected" do
      r = Reserve.create(@reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010"}))
      r.save!
      get :update, {:id=>r[:id], :reserve => @reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010"})}
      response.should redirect_to(edit_reserve_path(r[:id]))
      Reserve.find(r[:id]).term.should == current_term
    end
    it "should properly assign the sent_item_list for unsent items" do
      res = {:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010", :item_list=>[{"ckey"=>"12345"}]}
      r = Reserve.create(@reserve_params.merge(res))
      r.save!
      r.sent_item_list.should be_blank
      get :update, {:id=>r[:id], :send_request=>"true", :reserve=>res}
      Reserve.find(r[:id]).sent_item_list.should == [{"ckey"=>"12345"}]
    end
    it "should properly assign the sent_item-list for sent items" do
      res = {:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010", :item_list=>[{"ckey"=>"12345"}], :has_been_sent=>true, :sent_item_list=>[{"ckey"=>"12345"}]}
      r = Reserve.create(@reserve_params.merge(res))
      r.save!
      get :update, {:id=>r[:id], :send_request=>"true", :reserve=>res.merge({:item_list=>[{"ckey"=>"12345"}, {"ckey"=>"54321"}]})}
      Reserve.find(r[:id]).sent_item_list.should == [{"ckey"=>"12345"}, {"ckey"=>"54321"}]
    end
  end
  
  describe "clone" do
    it "should allow you to clone an item if you are an existing editor" do
      controller.stub(:current_user).and_return("user_sunet")
      r = Reserve.create(@reserve_params.merge(:cid=>"CID1", :compound_key => "CID1,user_sunet", :sid => "01", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :id => r.compound_key, :term => future_terms.first
      response.should redirect_to(edit_reserve_path((r[:id] + 1).to_s))
    end
    it "should allow you to clone an item if you are an super user" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      r = Reserve.create(@reserve_params.merge(:cid=>"CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :id => r.compound_key, :term => future_terms.first
      response.should redirect_to(edit_reserve_path((r[:id] + 1).to_s))
    end
    it "should transfer editor relationships to new object" do
      controller.stub(:current_user).and_return("user_sunet")
      r = Reserve.create(@reserve_params.merge(:cid=>"CID1", :sid => "01", :compound_key => "CID1,user_sunet", :term=> "Spring 2010", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :id => r.compound_key, :term => future_terms.first
      response.should redirect_to(edit_reserve_path((r[:id] + 1).to_s))
      cloned_reserve = Reserve.find((r[:id] + 1).to_s)
      cloned_reserve.term.should == future_terms.first
      cloned_reserve.editors.length.should == 1
      cloned_reserve.editors.map{|e| e[:sunetid]}.should == ["user_sunet"]
    end
    it "should redirect you to an existing course if you try to clone a course w/ the same term" do
      controller.stub(:current_user).and_return("user_sunet")
      r = Reserve.create(@reserve_params.merge(:cid=>"CID1", :sid => "01", :term=> "Spring 2010", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :id => r.compound_key, :term => "Spring 2010"
      response.should redirect_to(edit_reserve_path(r[:id]))
      flash[:error].should == "Course reserve list already exists for this course and term."
    end
    it "should not allow you to clone an item that you are not an editor of" do
      r = Reserve.create(@reserve_params.merge(:cid=>"CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :id => r.compound_key, :term => future_terms.first
      response.should redirect_to(root_path)
      flash[:error].should == "You do not have permission to clone this course reserve list."
    end
  end
  
  describe "index" do
    it "should return reserves for a user when they have them" do
      r = Reserve.create(@reserve_params.merge({:cid=>"CID1", :sid => "SID1", :instructor_sunet_ids => "user_sunet"}))
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
    it "should return parsable JSON of all courses for a super user" do
      # rwmantov is in the super_sunet list as of the writing of this test.
      controller.stub(:current_user).and_return("rwmantov")
      get :all_courses_response
      response.should be_success
      body = JSON.parse(response.body)
      body.keys.length.should == 1
      body.has_key?("aaData").should be_true
      body["aaData"].length.should == 7
      body["aaData"].each do |item|
        item.length.should == 3
      end
    end
    it "should return parsible JSON of the courese that you are an instructor for" do
      controller.stub(:current_user).and_return("456")
      get :all_courses_response
      response.should be_success
      body = JSON.parse(response.body)
      body.keys.length.should == 1
      body.has_key?("aaData").should be_true
      body["aaData"].length.should == 2
      body["aaData"].each do |item|
        item.length.should == 3
      end
    end
    it "should not return any courses if you are not a super user and you don't have any courses in the XML" do
      get :all_courses_response
      response.should be_success
      body = JSON.parse(response.body)
      body.keys.length.should == 1
      body.has_key?("aaData").should be_true
      body["aaData"].should be_blank
    end
  end
  
  
  describe "protected methods" do
    describe "email diff" do
      it "should return new items added to the item list" do
        old_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}]
        new_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"54321", "title"=>"SecondTitle", "copies"=>"1"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        diff_item_list.should match(/ADDED ITEM/)
        diff_item_list.should match(/CKey: 54321 : http:\/\/searchworks.stanford.edu\/view\/54321/)
        diff_item_list.should_not match(/EDITED ITEM/)
        diff_item_list.should_not match(/DELETED ITEM/)
      end
      it "should return changed items from the item list" do
        old_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey" => "54321", "title"=>"SecondTitle", "copies"=>"1"}]
        new_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey" => "54321", "title"=>"SecondTitle", "copies"=>"2"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        diff_item_list.should match(/EDITED ITEM/)
        diff_item_list.should match(/CKey: 54321 : http:\/\/searchworks.stanford.edu\/view\/54321/)
        diff_item_list.should match(/Copies: 2 \(was: 1\)/)
        diff_item_list.should_not match(/ADDED ITEM/)
        diff_item_list.should_not match(/DELETED ITEM/)
      end
      it "should return items deleted from the item list" do
        old_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"54321", "title"=>"ToBeDeleted", "copies"=>"1"}]
        new_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        diff_item_list.should match(/DELETED ITEM/)
        diff_item_list.should match(/CKey: 54321 : http:\/\/searchworks.stanford.edu\/view\/54321/)
        diff_item_list.should match(/Title: ToBeDeleted/)
        diff_item_list.should_not match(/ADDED ITEM/)
        diff_item_list.should_not match(/EDITED ITEM/)
      end
      it "should get an item w/ the same ckey that is drastically out of the old order" do
        old_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"23456", "title"=>"SecondTitle", "copies"=>"1"}, {"ckey"=>"34567", "title"=>"ThirdTitle", "copies"=>"1"}]
        new_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"34567", "title"=>"ThirdTitle", "copies"=>"1"}, {"ckey"=>"23456", "title"=>"ChangedTitle", "copies"=>"1"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        diff_item_list.should match(/EDITED ITEM/)
        diff_item_list.should match(/CKey: 23456 : http:\/\/searchworks.stanford.edu\/view\/23456/)
        diff_item_list.should match(/Title: ChangedTitle \(was: SecondTitle\)/)
        diff_item_list.should_not match(/ADDED ITEM/)
        diff_item_list.should_not match(/DELETED ITEM/)
      end
      it "should hadnel custom items w/ the same comment as the same items" do
        old_item_list = [{"ckey"=>"", "title"=>"", "comment"=>"This is Item1", "copies"=>"4", "loan_period"=>"2 hours"}, {"ckey"=>"", "title"=>"", "comment"=>"This is Item2", "copies"=>"1", "loan_period"=>"4 hours"}]
        new_item_list = [{"ckey"=>"", "title"=>"", "comment"=>"This is Item1", "copies"=>"4", "loan_period"=>"4 hours"}, {"ckey"=>"", "title"=>"", "comment"=>"This is Item2", "copies"=>"2", "loan_period"=>"4 hours"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        diff_item_list.should match(/EDITED ITEM/)
        diff_item_list.should match(/Circ rule: 4HWF-RES \(was: 2HWF-RES\)/)
        diff_item_list.should match(/Copies: 2 \(was: 1\)/)
        diff_item_list.should_not match(/ADDED ITEM/)
        diff_item_list.should_not match(/DELETED ITEM/)
      end
      
      it "should not return unchanged items from the item list" do
        old_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}]
        new_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        diff_item_list.should be_blank
      end
    end
    
  end
end
