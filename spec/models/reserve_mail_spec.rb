require 'rails_helper'

RSpec.describe ReserveMail do
  let(:reserve_params) do
    { cid: "CID1", instructor_sunet_ids: "jdoe, jondoe", instructor_names: "Doe, John, Doe, Jon", desc: "MySuperCoolCourse", sid: "SID1", library: "GREEN-RESV", term: "Spring 2010", contact_name: "John Doe", contact_phone: "555-555-5555", contact_email: "jdoe@example.com" }
  end

  describe ".first_request" do
    it "returns the correct main info" do
      email = ReserveMail.first_request(Reserve.create(reserve_params), "test@example.com", "jdoe")
      body = email.body.raw_source
      expect(email.subject).to  eq("New Reserve Form: CID1-SID1 - Spring 2010")
      expect(email.to).to include("test@example.com")
      expect(body).to match(/CID1-SID1/)
      expect(body).to match(/Instructor Name\(s\): Doe, John, Doe, Jon/)
      expect(body).to match(/Instructor SUNet ID\(s\): jdoe, jondoe/)
      expect(body).to match(/Reserve at: Green Library/)
      expect(body).to match(/Contact Name: John Doe/)
      expect(body).to match(/Contact Email: jdoe@example.com/)
      expect(body).to match(/Contact Phone: 555-555-5555/)
    end

    it "returns the item list formatted correctly" do
      email = ReserveMail.first_request(Reserve.create(reserve_params.merge(item_list: [{ "ckey" => "12345", "title" => "SW Item", 'imprint' => '1st ed. - Mordor', "copies" => "2", "loan_period" => "4 hours", "online" => true }])), "test@example.com", "jdoe")
      body = email.body.raw_source
      expect(body).to match(/Title: SW Item/)
      expect(body).to match(/Imprint: 1st ed\. - Mordor/)
      expect(body).to match(/CKey: 12345 : https:\/\/searchworks.stanford.edu\/view\/12345/)
      expect(body).to match(/Full text available online/)
    end

    it "has the full edit URL in the email" do
      email = ReserveMail.first_request(Reserve.create(reserve_params.merge(item_list: [{ "ckey" => "12345", "title" => "SW Item", "copies" => "2", "loan_period" => "4 hours" }])), "test@example.com", "jdoe")
      expect(email.body.raw_source).to match(/http:\/\/reserves.stanford.edu\/reserves\/1\/edit/)
    end
  end

  describe ".updated_request" do
    it "returns the correct main info for an updated request" do
      email = ReserveMail.updated_request(Reserve.create(reserve_params), "test@example.com", "DiffText", "jdoe")
      body = email.body.raw_source
      expect(email.subject).to  eq("Updated Reserve Form: CID1-SID1 - Spring 2010")
      expect(email.to).to include("test@example.com")
      expect(body).to match(/CID1-SID1/)
      expect(body).to match(/CID1-SID1/)
      expect(body).to match(/Instructor Name\(s\): Doe, John, Doe, Jon/)
      expect(body).to match(/Instructor SUNet ID\(s\): jdoe, jondoe/)
      expect(body).to match(/Reserve at: Green Library/)
      expect(body).to match(/Contact Name: John Doe/)
      expect(body).to match(/Contact Email: jdoe@example.com/)
      expect(body).to match(/Contact Phone: 555-555-5555/)
    end

    it "has the full edit URL in the email" do
      email = ReserveMail.updated_request(Reserve.create(reserve_params), "test@example.com", "DiffText", "jdoe")
      expect(email.body.raw_source).to match(/http:\/\/reserves.stanford.edu\/reserves\/1\/edit/)
    end
  end
end
