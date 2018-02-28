require 'rails_helper'
require 'terms'

RSpec.describe ReservesController do
  include Terms
  let(:reserve_params) do
    {:library => "Green", :immediate=>"true", :contact_name => "John Doe", :contact_phone=>"(555)555-5555", :contact_email=>"jdoe@example.com"}
  end
  describe "GET new" do
    it "should redirect to an existing course list if it exists and the current user is an editor" do
      r1 = Reserve.create(reserve_params.merge({:cid => "CID1", :sid => "02", :compound_key => "CID1,another_sunet" , :instructor_sunet_ids => "another_sunet", :term => "Winter 2012"}))
      r1.save!
      r = Reserve.create(reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet", :term => "Winter 2012"}))
      r.save!
      allow(controller).to receive(:current_user).and_return("user_sunet")
      get :new, :params => {:comp_key => "CID1,user_sunet"}
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end
    it "should redirect to an existing course list if it exists and the current user is a super user" do
      r = Reserve.create(reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet", :term => "Winter 2012"}))
      r.save!
      # rwmantov is in the super_sunet list as of the writing of this test.
      allow(controller).to receive_messages(superuser?: true)
      expect(r.editors.map{|e| e[:sunetid] }).to_not include("jdoe")
      get :new, :params => {:comp_key => "CID1,user_sunet"}
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end
    it "should let you create a new course if you are a super user" do
      allow(controller).to receive_messages(superuser?: true)
      get :new, :params => {:comp_key => "AFRICAAM-165E,EDUC-237X,ETHICSOC-165E,123,456"}
      expect(response).to be_successful
      course = assigns(:course)
      expect(course[:cid]).to eq("EDUC-237X")
      expect(course[:title]).to eq("Residential Racial Segregation and the Education of African-American Youth")
      expect(course[:instructors].map{|i| i[:sunet] }).to include("456")
    end
    it "should let you create a new course if you are the professor" do
      allow(controller).to receive(:current_user).and_return("123")
      get :new, :params => {:comp_key => "AA-272C,123,456"}
      expect(response).to be_successful
      course = assigns(:course)
      expect(course[:cid]).to eq("AA-272C")
      expect(course[:instructors].map{|i| i[:sunet] }).to include("456")
    end
    it "should not let you create a course that you don't have permisisons to" do
      get :new, :params => {:comp_key => "AA-272C,123,456"}
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq("You are not the instructor for this course.")
    end
  end

  describe "POST create" do
    it "should allow you to create an item if you are the instructor" do
      allow(controller).to receive(:current_user).and_return("user_sunet")
      post :create, :params => { :reserve => reserve_params.merge({:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"}) }
      r = assigns(:reserve)
      expect(r.cid).to eq("EDUC-237X")
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end
    it "should allow you to create an item if you are a super sunet" do
      allow(controller).to receive_messages(superuser?: true)
      post :create, :params => { :reserve => reserve_params.merge({:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"}) }
      r = assigns(:reserve)
      expect(r.cid).to eq("EDUC-237X")
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end
    it "should save the configured current term when immediate is selected" do
      allow(controller).to receive(:current_user).and_return("user_sunet")
      post :create, :params => { :reserve => reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010"}) }
      r = assigns[:reserve]
      expect(r.term).to eq(Terms.current_term)
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end
    it "should redirecto the home page if the user does not have access to create this reserve list" do
      allow(controller).to receive(:current_user).and_return("cannot_edit")
      post :create, :params => { :reserve => reserve_params.merge({:cid => "EDUC-237X", :sid=>"02", :term => "Winter 2012", :instructor_sunet_ids => "prof_a, user_sunet"}) }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq("You do not have permission to create this course reserve list.")
    end
  end

  describe "GET edit" do
    it "should allow you to get to the edit screen if you are an editor if the item" do
      allow(controller).to receive(:current_user).and_return("user_sunet")
      r = Reserve.create(reserve_params.merge({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"}))
      r.save!
      get :edit, :params => { :id => r[:id] }
      expect(response).to be_successful
      expect(assigns(:reserve)).to eq(r)
    end
    it "should allow you to get to the edit screen if you are an super sunet" do
      allow(controller).to receive_messages(superuser?: true)
      r = Reserve.create(reserve_params.merge({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"}))
      r.save!
      get :edit, :params => { :id => r[:id] }
      expect(response).to be_successful
      expect(assigns(:reserve)).to eq(r)
    end
    it "should redirect if the user does not have permissions to edit the reserve" do
      allow(controller).to receive(:current_user).and_return("some_user")
      r = Reserve.create(reserve_params.merge({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet"}))
      r.save!
      get :edit, :params => { :id => r[:id] }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq("You do not have permission to edit this course reserve list.")
    end
  end

  describe "GET update" do
    it "should clear out the item_list if no item_list params is in the URL" do
      r = Reserve.create(reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :item_list => [{:ckey => "item1"}]}))
      r.save!
      expect(r.item_list.length).to eq(1)
      get :update, :params => {:id => r[:id], :reserve => {:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet"}}
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
      expect(Reserve.find(r[:id]).item_list).to be_blank
    end
    it "should not allow you to update a reserve w/ a term that already has a record in the database" do
      r1 = Reserve.create(reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :term => "Spring 2012", :instructor_sunet_ids => "user_sunet"}))
      r2 = Reserve.create(reserve_params.merge({:cid => "CID1", :sid => "01", :compound_key => "CID1,user_sunet", :term => "Summer 2012", :instructor_sunet_ids => "user_sunet"}))
      r1.save!
      r2.save!
      get :update, :params => {:id => r2[:id], :reserve => {:cid => "CID1", :sid => "01", :term => "Spring 2012"}}
      expect(response).to redirect_to(edit_reserve_path(r2[:id]))
      expect(Reserve.find(r2[:id]).term).to eq("Summer 2012")
      expect(flash[:error]).to eq("Course reserve list already exists for this course and term. The term has not been saved.")
    end
    it "should save the configured current term when immediate is selected" do
      r = Reserve.create(reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010"}))
      r.save!
      get :update, :params => {:id=>r[:id], :reserve => reserve_params.merge({:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010"})}
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
      expect(Reserve.find(r[:id]).term).to eq(Terms.current_term)
    end
    it "should properly assign the sent_item_list for unsent items" do
      res = {:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010", :item_list=>[{"ckey"=>"12345"}]}
      r = Reserve.create(reserve_params.merge(res))
      r.save!
      expect(r.sent_item_list).to be_blank
      get :update, :params => {:id=>r[:id], :send_request=>"true", :reserve=>res}
      expect(Reserve.find(r[:id]).sent_item_list).to eq([{"ckey"=>"12345"}])
    end
    it "should properly assign the sent_item-list for sent items" do
      res = {:cid => "CID1", :sid => "01", :instructor_sunet_ids => "user_sunet", :immediate=>"true", :term=>"Summer 2010", :item_list=>[{"ckey"=>"12345"}], :has_been_sent=>true, :sent_item_list=>[{"ckey"=>"12345"}]}
      r = Reserve.create(reserve_params.merge(res))
      r.save!
      get :update, :params => {:id=>r[:id], :send_request=>"true", :reserve=>res.merge({:item_list=>[{"ckey"=>"12345"}, {"ckey"=>"54321"}]})}
      expect(Reserve.find(r[:id]).sent_item_list).to eq([{"ckey"=>"12345"}, {"ckey"=>"54321"}])
    end
  end

  describe "GET clone" do
    it "should allow you to clone an item if you are an existing editor" do
      allow(controller).to receive(:current_user).and_return("user_sunet")
      r = Reserve.create(reserve_params.merge(:cid=>"CID1", :compound_key => "CID1,user_sunet", :sid => "01", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :params => { :id => r.compound_key, :term => Terms.future_terms.first }
      expect(response).to redirect_to(edit_reserve_path((r[:id] + 1).to_s))
    end
    it "should allow you to clone an item if you are an super user" do
      allow(controller).to receive_messages(superuser?: true)
      r = Reserve.create(reserve_params.merge(:cid=>"CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :params => { :id => r.compound_key, :term => Terms.future_terms.first }
      expect(response).to redirect_to(edit_reserve_path((r[:id] + 1).to_s))
    end
    it "should transfer editor relationships to new object" do
      allow(controller).to receive(:current_user).and_return("user_sunet")
      r = Reserve.create(reserve_params.merge(:cid=>"CID1", :sid => "01", :compound_key => "CID1,user_sunet", :term=> "Spring 2010", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :params => { :id => r.compound_key, :term => Terms.future_terms.first }
      expect(response).to redirect_to(edit_reserve_path((r[:id] + 1).to_s))
      cloned_reserve = Reserve.find((r[:id] + 1).to_s)
      expect(cloned_reserve.term).to eq(Terms.future_terms.first)
      expect(cloned_reserve.editors.length).to eq(1)
      expect(cloned_reserve.editors.map{|e| e[:sunetid]}).to eq(["user_sunet"])
    end
    it "should redirect you to an existing course if you try to clone a course w/ the same term" do
      allow(controller).to receive(:current_user).and_return("user_sunet")
      r = Reserve.create(reserve_params.merge(:cid=>"CID1", :sid => "01", :term=> "Spring 2010", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :params => { :id => r.compound_key, :term => "Spring 2010" }
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
      expect(flash[:error]).to eq("Course reserve list already exists for this course and term.")
    end
    it "should not allow you to clone an item that you are not an editor of" do
      r = Reserve.create(reserve_params.merge(:cid=>"CID1", :sid => "01", :compound_key => "CID1,user_sunet", :instructor_sunet_ids => "user_sunet"))
      r.save!
      get :clone, :params => { :id => r.compound_key, :term => Terms.future_terms.first }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq("You do not have permission to clone this course reserve list.")
    end
  end

  describe "GET index" do
    it "should return reserves for a user when they have them" do
      r = Reserve.create(reserve_params.merge({:cid=>"CID1", :sid => "SID1", :instructor_sunet_ids => "user_sunet"}))
      r.save!
      allow(controller).to receive(:current_user).and_return("user_sunet")
      get :index
      expect(response).to be_successful
      my_reserves = assigns(:my_reserves)
      expect(my_reserves.length).to eq(1)
      expect(my_reserves.first.cid).to eq("CID1")
      expect(my_reserves.first.sid).to eq("SID1")
    end
  end

  describe "GET all_courses" do
    it "should return parsable JSON of all courses for a super user" do
      allow(controller).to receive_messages(superuser?: true)
      get :all_courses_response
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.keys.length).to eq(1)
      expect(body).to have_key("aaData")
      expect(body["aaData"].length).to eq(7)
      body["aaData"].each do |item|
        expect(item.length).to eq(3)
      end
    end
    it "should return parsible JSON of the courese that you are an instructor for" do
      allow(controller).to receive(:current_user).and_return("456")
      get :all_courses_response
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.keys.length).to eq(1)
      expect(body).to have_key("aaData")
      expect(body["aaData"].length).to eq(2)
      body["aaData"].each do |item|
        expect(item.length).to eq(3)
      end
    end
    it "should not return any courses if you are not a super user and you don't have any courses in the XML" do
      get :all_courses_response
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.keys.length).to eq(1)
      expect(body).to have_key("aaData")
      expect(body["aaData"]).to be_blank
    end
  end

  describe "email sending contoller methods" do
    describe "send_course_reserve_request" do
      it "should use the most updates reserve information to determine the TO address for emails" do
        allow(controller).to receive_messages :reserve_params => {}
        r = Reserve.create(reserve_params.merge({:cid=>"CID1", :sid=>"SID1", :instructor_sunet_ids=>"user_sunet", :library=>"ENG-RESV"}))
        r.save!
        mail = controller.send(:send_course_reserve_request, r)
        expect(mail.to).to eq(["englibrary@stanford.edu", "course-reserves-allforms@lists.stanford.edu"])
        allow(controller).to receive_messages :reserve_params => {:library=>"GREEN-RESV"}
        mail = controller.send(:send_course_reserve_request, r)
        expect(mail.to).to eq(["greenreserves@stanford.edu", "course-reserves-allforms@lists.stanford.edu"])
        expect(r.library).to eq("GREEN-RESV")
      end

    end
  end

  describe "protected methods" do
    describe "email diff" do
      it "should return new items added to the item list" do
        old_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}]
        new_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"54321", "title"=>"SecondTitle", "copies"=>"1"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        expect(diff_item_list).to match(/ADDED ITEM/)
        expect(diff_item_list).to match(/CKey: 54321 : https:\/\/searchworks.stanford.edu\/view\/54321/)
        expect(diff_item_list).not_to match(/EDITED ITEM/)
        expect(diff_item_list).not_to match(/DELETED ITEM/)
      end
      it "should return changed items from the item list" do
        old_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey" => "54321", "title"=>"SecondTitle", "copies"=>"1"}]
        new_item_list = [{"ckey" => "12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey" => "54321", "title"=>"SecondTitle", "copies"=>"2"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        expect(diff_item_list).to match(/EDITED ITEM/)
        expect(diff_item_list).to match(/CKey: 54321 : https:\/\/searchworks.stanford.edu\/view\/54321/)
        expect(diff_item_list).to match(/Copies: 2 \(was: 1\)/)
        expect(diff_item_list).not_to match(/ADDED ITEM/)
        expect(diff_item_list).not_to match(/DELETED ITEM/)
      end
      it "should return items deleted from the item list" do
        old_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"54321", "title"=>"ToBeDeleted", "copies"=>"1"}]
        new_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        expect(diff_item_list).to match(/DELETED ITEM/)
        expect(diff_item_list).to match(/CKey: 54321 : https:\/\/searchworks.stanford.edu\/view\/54321/)
        expect(diff_item_list).to match(/Title: ToBeDeleted/)
        expect(diff_item_list).not_to match(/ADDED ITEM/)
        expect(diff_item_list).not_to match(/EDITED ITEM/)
      end
      it "should get an item w/ the same ckey that is drastically out of the old order" do
        old_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"23456", "title"=>"SecondTitle", "copies"=>"1"}, {"ckey"=>"34567", "title"=>"ThirdTitle", "copies"=>"1"}]
        new_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}, {"ckey"=>"34567", "title"=>"ThirdTitle", "copies"=>"1"}, {"ckey"=>"23456", "title"=>"ChangedTitle", "copies"=>"1"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        expect(diff_item_list).to match(/EDITED ITEM/)
        expect(diff_item_list).to match(/CKey: 23456 : https:\/\/searchworks.stanford.edu\/view\/23456/)
        expect(diff_item_list).to match(/Title: ChangedTitle \(was: SecondTitle\)/)
        expect(diff_item_list).not_to match(/ADDED ITEM/)
        expect(diff_item_list).not_to match(/DELETED ITEM/)
      end
      it "should hadnel custom items w/ the same comment as the same items" do
        old_item_list = [{"ckey"=>"", "title"=>"", "comment"=>"This is Item1", "copies"=>"4", "loan_period"=>"2 hours"}, {"ckey"=>"", "title"=>"", "comment"=>"This is Item2", "copies"=>"1", "loan_period"=>"4 hours"}]
        new_item_list = [{"ckey"=>"", "title"=>"", "comment"=>"This is Item1", "copies"=>"4", "loan_period"=>"4 hours"}, {"ckey"=>"", "title"=>"", "comment"=>"This is Item2", "copies"=>"2", "loan_period"=>"4 hours"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        expect(diff_item_list).to match(/EDITED ITEM/)
        expect(diff_item_list).to match(/Circ rule: 4HWF-RES \(was: 2HWF-RES\)/)
        expect(diff_item_list).to match(/Copies: 2 \(was: 1\)/)
        expect(diff_item_list).not_to match(/ADDED ITEM/)
        expect(diff_item_list).not_to match(/DELETED ITEM/)
      end

      it "should not return unchanged items from the item list" do
        old_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}]
        new_item_list = [{"ckey"=>"12345", "title"=>"FirstTitle", "copies"=>"4"}]
        diff_item_list = controller.send(:process_diff, old_item_list, new_item_list)
        expect(diff_item_list).to be_blank
      end
    end

  end
end
