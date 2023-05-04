require 'rails_helper'
require 'terms'

RSpec.describe ReservesController do
  include Terms
  let(:reserve_params) do
    { library: "Green", term: Terms.current_term, contact_name: "John Doe", contact_phone: "(555)555-5555", contact_email: "jdoe@example.com" }
  end

  let(:user) { instance_double('CurrentUser', sunetid: 'user_sunet', superuser?: false) }
  let(:user_456) { instance_double('CurrentUser', sunetid: '456', superuser?: false) }
  let(:superuser) { instance_double('CurrentUser', sunetid: 'super-user', superuser?: true) }

  describe "GET new" do
    it "redirects to an existing course list if it exists and the current user is an editor" do
      r1 = Reserve.create(reserve_params.merge(cid: "CID1", sid: "02", compound_key: "CID1,another_sunet", instructor_sunet_ids: "another_sunet",
                                               term: "Winter 2012"))
      r1.save!
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", compound_key: "CID1,user_sunet", instructor_sunet_ids: "user_sunet",
                                              term: "Winter 2012"))
      r.save!
      allow(controller).to receive(:current_user).and_return(user)
      get :new, params: { comp_key: "CID1,user_sunet" }
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end

    it "redirects to an existing course list if it exists and the current user is a super user" do
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", compound_key: "CID1,user_sunet", instructor_sunet_ids: "user_sunet",
                                              term: "Winter 2012"))
      r.save!

      allow(controller).to receive_messages(current_user: user)
      get :new, params: { comp_key: "CID1,user_sunet" }
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end

    it "lets you create a new course if you are a super user" do
      allow(controller).to receive_messages(current_user: superuser)
      get :new, params: { comp_key: "AFRICAAM-165E,EDUC-237X,ETHICSOC-165E,123,456" }
      expect(response).to be_successful
      course = assigns(:course)
      expect(course.cid).to eq("EDUC-237X")
      expect(course.title).to eq("Residential Racial Segregation and the Education of African-American Youth")
      expect(course.instructors.map { |i| i[:sunet] }).to include("456")
    end

    it "lets you create a new course if you are the professor" do
      allow(controller).to receive(:current_user).and_return(user_456)
      get :new, params: { comp_key: "AA-272C,123,456" }
      expect(response).to be_successful
      course = assigns(:course)
      expect(course.cid).to eq("AA-272C")
      expect(course.instructors.map { |i| i[:sunet] }).to include("456")
    end

    it "does not let you create a course that you don't have permisisons to" do
      expect do
        get :new, params: { comp_key: "AA-272C,123,456" }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "POST create" do
    it "allows you to create an item if you are the instructor" do
      allow(controller).to receive(:current_user).and_return(user_456)
      post :create,
           params: { reserve: reserve_params.merge(cid: 'AA-272C', compound_key: 'AA-272C,123,456', sid: "02", term: "Winter 2012",
                                                   instructor_sunet_ids: "prof_a, user_sunet") }
      r = assigns(:reserve)
      expect(r.cid).to eq('AA-272C')
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end

    it "allows you to create an item if you are a super sunet" do
      allow(controller).to receive_messages(current_user: superuser)
      post :create,
           params: { reserve: reserve_params.merge(cid: 'AA-272C', compound_key: 'AA-272C,123,456', sid: "02", term: "Winter 2012",
                                                   instructor_sunet_ids: "prof_a, user_sunet") }
      r = assigns(:reserve)
      expect(r.cid).to eq('AA-272C')
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
    end

    it "raises an error if the user does not have access to create this reserve list" do
      allow(controller).to receive(:current_user).and_return(CurrentUser.new('not-authed'))

      expect do
        post :create,
             params: { reserve: reserve_params.merge(cid: "AA-272C", compound_key: 'AA-272C,123,456', sid: "02", term: "Winter 2012",
                                                     instructor_sunet_ids: "prof_a, user_sunet") }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "GET edit" do
    it "allows you to get to the edit screen if you are an editor if the item" do
      allow(controller).to receive(:current_user).and_return(user)
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "SID1", instructor_sunet_ids: "user_sunet"))
      r.save!
      get :edit, params: { id: r[:id] }
      expect(response).to be_successful
      expect(assigns(:reserve)).to eq(r)
    end

    it "allows you to get to the edit screen if you are an super sunet" do
      allow(controller).to receive_messages(current_user: superuser)
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "SID1", instructor_sunet_ids: "user_sunet"))
      r.save!
      get :edit, params: { id: r[:id] }
      expect(response).to be_successful
      expect(assigns(:reserve)).to eq(r)
    end

    it "redirects if the user does not have permissions to edit the reserve" do
      allow(controller).to receive(:current_user).and_return(user_456)
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "SID1", instructor_sunet_ids: "user_sunet"))
      r.save!
      expect do
        get :edit, params: { id: r[:id] }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "GET update" do
    it "clears out the item_list if no item_list params is in the URL" do
      expect(controller).to receive_messages(current_user: user)
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", instructor_sunet_ids: "user_sunet", item_list: [{ ckey: "item1" }]))
      r.save!
      expect(r.item_list.length).to eq(1)
      get :update, params: { id: r[:id], reserve: { cid: "CID1", sid: "01", instructor_sunet_ids: "user_sunet" } }
      expect(response).to redirect_to(edit_reserve_path(r[:id]))
      expect(Reserve.find(r[:id]).item_list).to be_blank
    end

    it "does not allow you to update a reserve w/ a term that already has a record in the database" do
      expect(controller).to receive_messages(current_user: user)
      r1 = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", compound_key: "CID1,user_sunet", term: "Spring 2012",
                                               instructor_sunet_ids: "user_sunet"))
      r2 = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", compound_key: "CID1,user_sunet", term: "Summer 2012",
                                               instructor_sunet_ids: "user_sunet"))
      r1.save!
      r2.save!
      get :update, params: { id: r2[:id], reserve: { cid: "CID1", sid: "01", term: "Spring 2012" } }
      expect(response).to redirect_to(edit_reserve_path(r2[:id]))
      expect(Reserve.find(r2[:id]).term).to eq("Summer 2012")
      expect(flash[:error]).to eq("Course reserve list already exists for this course and term. The term has not been saved.")
    end

    it "properlies assign the sent_item_list for unsent items" do
      expect(controller).to receive_messages(current_user: user)
      item_list = { 0 => { "ckey" => "12345" } }
      res = { cid: "CID1", sid: "01", instructor_sunet_ids: "user_sunet", term: "Summer 2010", item_list: item_list.values }
      r = Reserve.create(reserve_params.merge(res))
      r.save!
      expect(r.sent_item_list).to be_blank
      get :update, params: { id: r[:id], send_request: "true", reserve: res.merge(item_list: item_list) }
      expect(Reserve.find(r[:id]).sent_item_list).to match_array([hash_including({ "ckey" => "12345" })])
    end

    it "properlies assign the sent_item-list for sent items" do
      expect(controller).to receive_messages(current_user: user)
      res = { cid: "CID1", sid: "01", instructor_sunet_ids: "user_sunet", term: "Summer 2010", item_list: [{ "ckey" => "12345" }],
              sent_item_list: [{ "ckey" => "12345" }] }
      r = Reserve.create(reserve_params.merge(res))
      r.save!
      get :update,
          params: { id: r[:id], send_request: "true",
                    reserve: res.merge(item_list: { 0 => { "ckey" => "12345" }, 'whatever' => { "ckey" => "54321" } }) }
      expect(Reserve.find(r[:id]).sent_item_list).to match_array([hash_including({ "ckey" => "12345" }), hash_including({ "ckey" => "54321" })])
    end

    it 'allows superusers to update any record' do
      expect(controller).to receive_messages(current_user: superuser)
      res = { cid: "CID1", sid: "01", instructor_sunet_ids: "user_sunet", term: "Summer 2010", item_list: [{ "ckey" => "12345" }],
              has_been_sent: true, sent_item_list: [{ "ckey" => "12345" }] }
      r = Reserve.create(reserve_params.merge(res))
      r.save!
      get :update,
          params: { id: r[:id], send_request: "true", reserve: res.merge(item_list: { 0 => { "ckey" => "12345" }, '42' => { "ckey" => "54321" } }) }
      expect(Reserve.find(r[:id]).sent_item_list).to match_array([hash_including({ "ckey" => "12345" }), hash_including({ "ckey" => "54321" })])
    end

    it 'does not allow you to update a record you are not an editor of' do
      expect(controller).to receive_messages(current_user: user)
      res = { cid: "CID1", sid: "01", instructor_sunet_ids: 'some_other_user', term: "Summer 2010", item_list: [{ "ckey" => "12345" }],
              has_been_sent: true, sent_item_list: [{ "ckey" => "12345" }] }
      r = Reserve.create(reserve_params.merge(res))
      r.save!

      expect do
        get :update,
            params: { id: r[:id], send_request: "true", reserve: res.merge(item_list: { 0 => { "ckey" => "12345" }, 1 => { "ckey" => "54321" } }) }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "GET clone" do
    it "allows you to clone an item if you are an existing editor" do
      allow(controller).to receive(:current_user).and_return(user)
      r = Reserve.create(reserve_params.merge(cid: "CID1", compound_key: "CID1,user_sunet", sid: "01", instructor_sunet_ids: "user_sunet",
                                              has_been_sent: true))
      r.save!
      get :clone, params: { id: r.id, term: Terms.future_terms.first }
      expect(response).to redirect_to(edit_reserve_path((r[:id] + 1).to_s))
    end

    it "allows you to clone an item if you are an super user" do
      allow(controller).to receive_messages(current_user: superuser)
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", compound_key: "CID1,user_sunet", instructor_sunet_ids: "user_sunet",
                                              has_been_sent: true))
      r.save!
      get :clone, params: { id: r.id, term: Terms.future_terms.first }
      expect(response).to redirect_to(edit_reserve_path((r[:id] + 1).to_s))
    end

    it "transfers editor relationships to new object" do
      allow(controller).to receive(:current_user).and_return(user)
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", compound_key: "CID1,user_sunet", term: "Spring 2010",
                                              instructor_sunet_ids: "user_sunet", has_been_sent: true))
      r.save!
      get :clone, params: { id: r.id, term: Terms.future_terms.first }
      expect(response).to redirect_to(edit_reserve_path((r[:id] + 1).to_s))
      cloned_reserve = Reserve.find((r[:id] + 1).to_s)
      expect(cloned_reserve.term).to eq(Terms.future_terms.first)
      expect(cloned_reserve.editors.length).to eq(1)
      expect(cloned_reserve.editors.map { |e| e[:sunetid] }).to eq(["user_sunet"])
    end

    it "redirects you to an existing course if you try to clone a course w/ the same term" do
      allow(controller).to receive(:current_user).and_return(user)
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", term: "Spring 2010", compound_key: "CID1,user_sunet",
                                              instructor_sunet_ids: "user_sunet", has_been_sent: true))
      r.save!
      get :clone, params: { id: r.id, term: "Spring 2010" }
      expect(response).to redirect_to(edit_reserve_path(r.id))
      expect(flash[:error]).to eq("Course reserve list already exists for this course and term.")
    end

    it "does not allow you to clone an item that you are not an editor of" do
      r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "01", compound_key: "CID1,user_sunet", instructor_sunet_ids: "user_sunet",
                                              has_been_sent: true))
      r.save!
      expect do
        get :clone, params: { id: r.id, term: Terms.future_terms.first }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "GET index" do
    it "returns reserves for a user when they have them" do
      Reserve.create(reserve_params.merge(cid: "CID1", compound_key: 'CID1,user_sunet', sid: "SID1", instructor_sunet_ids: "user_sunet"))
      allow(controller).to receive(:current_user).and_return(user)
      get :index
      expect(response).to be_successful
      reserves = assigns(:reserves)
      expect(reserves.length).to eq(1)
      expect(reserves.first.cid).to eq("CID1")
      expect(reserves.first.sid).to eq("SID1")
    end

    context 'when the user is a super admin' do
      it 'onlies see reserve lists that they are explicitly listed as an editor' do
        allow(controller).to receive(:current_user).and_return(superuser)
        Reserve.create(reserve_params.merge(cid: "CID1", compound_key: 'CID1,user_sunet', sid: "SID1", instructor_sunet_ids: "user_sunet"))
        Reserve.create(reserve_params.merge(cid: "CID2", compound_key: 'CID1,super-user', sid: "SID1", instructor_sunet_ids: "super-user"))

        get :index
        expect(response).to be_successful
        reserves = assigns(:reserves)

        expect(reserves.length).to eq(1)
        expect(reserves.first.cid).to eq('CID2')
      end
    end
  end

  describe "GET all_courses" do
    it "returns parsable JSON of all courses for a super user" do
      allow(controller).to receive(:current_user).and_return(superuser)
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

    it "returns parsible JSON of the courese that you are an instructor for" do
      allow(controller).to receive(:current_user).and_return(user_456)
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

    it "does not return any courses if you are not a super user and you don't have any courses in the XML" do
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
      it "uses the most updates reserve information to determine the TO address for emails" do
        allow(controller).to receive_messages(reserve_params: {}, current_user: user)
        r = Reserve.create(reserve_params.merge(cid: "CID1", sid: "SID1", instructor_sunet_ids: "user_sunet", library: "ENG-RESV"))
        r.save!
        mail = controller.send(:send_course_reserve_request, r)
        expect(mail.to).to eq(["englibrary@stanford.edu", "course-reserves-allforms@lists.stanford.edu"])
        r.update(library: "GREEN-RESV")
        mail = controller.send(:send_course_reserve_request, r)
        expect(mail.to).to eq(["greenreserves@stanford.edu", "course-reserves-allforms@lists.stanford.edu"])
        expect(r.library).to eq("GREEN-RESV")
      end
    end
  end
end
