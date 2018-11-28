require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#item_in_searchworks?" do
    it "returns true when we directly pass :sw throug the URL" do
      params[:sw] = "true"
      expect(item_in_searchworks?({})).to be_truthy
    end

    it "returns true if an item has a ckey" do
      expect(item_in_searchworks?({ "ckey" => "54321" })).to be_truthy
    end

    it "returns false when neither the params nor the item indicate it is a SearchWorks item" do
      expect(item_in_searchworks?({ comment: "hello", copies: "3", loan_period: "1 day" })).to be_falsey
    end
  end

  describe '#has_existing_reserve_for_term?' do
    let(:reserve) { Reserve.new(compound_key: 'ABC-123') }
    let(:other_reserve) { Reserve.new(compound_key: 'ABC-123', term: 'Winter') }

    before do
      # populate the database
      other_reserve.save!
    end

    it 'is true if there exists a reserve for the course in the given term' do
      expect(helper.has_existing_reserve_for_term?(reserve, 'Winter')).to eq true
    end

    it 'is false if there is not a reserve for the course in the given term' do
      expect(helper.has_existing_reserve_for_term?(reserve, 'Spring')).to eq false
    end

    it 'is false if there existing reserve is for the current course' do
      expect(helper.has_existing_reserve_for_term?(other_reserve, 'Spring')).to eq false
    end
  end

  describe '#render_term_label' do
    it 'returns the label for a future term' do
      expect(helper.render_term_label('Winter 1234')).to eq 'Winter 1234'
    end

    it 'flags the current quarter' do
      allow(Terms).to receive(:current_term).and_return('Winter 4321')
      expect(helper.render_term_label('Winter 4321')).to eq 'Winter 4321 (current quarter)'
    end
  end
  describe '#sortable_term_value' do
    it 'returns the term\'s end date' do
      expect(sortable_term_value('Spring 2018').to_s).to eq '2018-06-13'
    end
  end
end
