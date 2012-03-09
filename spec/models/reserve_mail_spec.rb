require 'spec_helper'

describe ReserveMail do
  before(:all) do
    @reserve_params = {:cid=>"CID1", :instructor_sunet_ids => "jdoe, jondoe", :instructor_names => "Doe, John, Doe, Jon", :desc => "MySuperCoolCourse", :sid => "SID1", :library => "GREEN-RESV", :term=>"Spring 2010", :contact_name => "John Doe", :contact_phone => "555-555-5555", :contact_email => "jdoe@example.com"}
  end
  describe "first_request" do
    it "should return the correct main info" do
      email = ReserveMail.first_request(Reserve.create(@reserve_params), "test@example.com")
      body = email.body.raw_source
      email.subject.should  == "New Reserve Form: CID1-SID1 - Spring 2010"
      email.to.include?("test@example.com").should be_true
      body.should match(/CID1-SID1/)
      body.should match(/Instructor Name\(s\): Doe, John, Doe, Jon/)
      body.should match(/Instructor SUNet ID\(s\): jdoe, jondoe/)
      body.should match(/Reserve at: Green Library/)
      body.should match(/Contact Name: John Doe/)
      body.should match(/Contact Email: jdoe@example.com/)
      body.should match(/Contact Phone: 555-555-5555/)
    end
    it "should return the item list formatted correctly" do
      email = ReserveMail.first_request(Reserve.create(@reserve_params.merge(:item_list=>[{"ckey"=>"12345", "title"=>"SW Item", "copies"=>"2", "loan_period"=>"4 hours"}])), "test@example.com")
      body = email.body.raw_source
      body.should match(/Title: SW Item/)
      body.should match(/CKey: 12345 : http:\/\/searchworks.stanford.edu\/view\/12345/)
      body.should match(/Circ rule: 4HWF-RES/)
      body.should match(/Copies: 2/)
    end
    it "should have the full edit URL in the email" do
      email = ReserveMail.first_request(Reserve.create(@reserve_params.merge(:item_list=>[{"ckey"=>"12345", "title"=>"SW Item", "copies"=>"2", "loan_period"=>"4 hours"}])), "test@example.com")
      email.body.raw_source.should match(/http:\/\/reserves.stanford.edu\/reserves\/1\/edit/)
    end
  end
  describe "updated_request" do
    it "should return the correct main info for an updated request" do
      email = ReserveMail.updated_request(Reserve.create(@reserve_params), "test@example.com", "DiffText")
      body = email.body.raw_source
      email.subject.should  == "Updated Reserve Form: CID1-SID1 - Spring 2010"
      email.to.include?("test@example.com").should be_true
      body.should match(/CID1-SID1/)
      body.should match(/CID1-SID1/)
      body.should match(/Instructor Name\(s\): Doe, John, Doe, Jon/)
      body.should match(/Instructor SUNet ID\(s\): jdoe, jondoe/)
      body.should match(/Reserve at: Green Library/)
      body.should match(/Contact Name: John Doe/)
      body.should match(/Contact Email: jdoe@example.com/)
      body.should match(/Contact Phone: 555-555-5555/)
    end
    it "should have the full edit URL in the email" do
      email = ReserveMail.updated_request(Reserve.create(@reserve_params), "test@example.com", "DiffText")
      email.body.raw_source.should match(/http:\/\/reserves.stanford.edu\/reserves\/1\/edit/)
    end
  end
end