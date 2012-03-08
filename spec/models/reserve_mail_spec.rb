require 'spec_helper'

describe ReserveMail do
  before(:all) do
    @reserve_params = {:cid=>"CID1", :instructor_sunet_ids => "jdoe, jondoe", :instructor_names => "Doe, John, Doe, Jon", :desc => "MySuperCoolCourse", :sid => "SID1", :library => "Green Library", :term=>"Spring 2010", :contact_name => "John Doe", :contact_phone => "555-555-5555", :contact_email => "jdoe@example.com"}
  end
  describe "first_request" do
    it "should return the correct main info" do
      email = ReserveMail.first_request(Reserve.create(@reserve_params))
      body = email.body.raw_source
      email.subject.should  == "New Reserve Form: CID1-SID1 - Spring 2010"
      body.should match(/CID1-SID1/)
      body.should match(/Doe, John, Doe, Jon/)
      body.should match(/jdoe, jondoe/)
      body.should match(/Reserve at: Green Library/)
      body.should match(/Contact Name: John Doe/)
      body.should match(/Contact Email: jdoe@example.com/)
      body.should match(/Contact Phone: 555-555-5555/)
    end
    it "should return the item list formatted correctly" do
      email = ReserveMail.first_request(Reserve.create(@reserve_params.merge(:item_list=>[{"ckey"=>"12345", "title"=>"SW Item", "copies"=>"2", "loan_period"=>"4 hours"}])))
      body = email.body.raw_source
      body.should match(/Title: SW Item/)
      body.should match(/CKey: 12345 : http:\/\/searchworks.stanford.edu\/view\/12345/)
      body.should match(/Loan Period: 4 hours/)
      body.should match(/Copies: 2/)
    end
  end
  describe "updated_request" do
    it "should return the correct main info for an updated request" do
      email = ReserveMail.updated_request(Reserve.create(@reserve_params), "DiffText")
      body = email.body.raw_source
      email.subject.should  == "Updated Reserve Form: CID1-SID1 - Spring 2010"
      body.should match(/CID1-SID1/)
      body.should match(/CID1-SID1/)
      body.should match(/Doe, John, Doe, Jon/)
      body.should match(/jdoe, jondoe/)
      body.should match(/Reserve at: Green Library/)
      body.should match(/Contact Name: John Doe/)
      body.should match(/Contact Email: jdoe@example.com/)
      body.should match(/Contact Phone: 555-555-5555/)
    end
  end
end