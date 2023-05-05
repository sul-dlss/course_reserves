require 'rails_helper'

RSpec.describe ReserveMailer do
  let(:reserve_params) do
    { cid: "CID1", instructor_sunet_ids: "jdoe, jondoe", instructor_names: "Doe, John, Doe, Jon", desc: "MySuperCoolCourse", sid: "SID1",
      library: "GREEN-RESV", term: "Spring 2010", contact_name: "John Doe", contact_phone: "555-555-5555", contact_email: "jdoe@example.com" }
  end

  describe ".first_request" do
    it "returns the correct main info" do
      email = described_class.submit_request(Reserve.create(reserve_params), "test@example.com", "jdoe")
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
      email = described_class.submit_request(
        Reserve.create(reserve_params.merge(item_list: [{ "ckey" => "12345", "title" => "SW Item", 'imprint' => '1st ed. - Mordor', "copies" => "2",
                                                          "loan_period" => "4 hours", "online" => true }])), "test@example.com", "jdoe"
      )
      body = email.body.raw_source
      expect(body).to match(/1. SW Item/)
      expect(body).to match(/1st ed\. - Mordor/)
      expect(body).to match(/Full text available online/)
      expect(body).to match(%r{https://searchworks.stanford.edu/view/12345})
    end

    it "has the full edit URL in the email" do
      email = described_class.submit_request(
        Reserve.create(reserve_params.merge(item_list: [{ "ckey" => "12345", "title" => "SW Item", "copies" => "2",
                                                          "loan_period" => "4 hours" }])), "test@example.com", "jdoe"
      )
      expect(email.body.raw_source).to match(%r{http://reserves.stanford.edu/reserves/1/edit})
    end

    context 'with an updated request' do
      it "uses the correct title info for an updated request" do
        email = described_class.submit_request(
          Reserve.create(reserve_params.merge(has_been_sent: true,
                                              item_list: [{ "ckey" => "12345", "title" => "SW Item", 'imprint' => '1st ed. - Mordor', "copies" => "2", "loan_period" => "4 hours",
                                                            "online" => true }])), "test@example.com", "jdoe"
        )
        expect(email.subject).to eq("Updated Reserve Form: CID1-SID1 - Spring 2010")
      end
    end
  end
end
