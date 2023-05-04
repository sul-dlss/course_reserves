require 'spec_helper'
require 'terms'

RSpec.describe Terms do
  subject(:terms) { Terms }

  describe "current_term_hash" do
    it "returns the appropriate term in the middle of a term" do
      term = terms.send(:current_term_hash, Date.new(2017, 7, 10))
      expect(term[:term]).to eq("Summer 2017")
    end

    it "returns the appropriate term on the last day of the quarter" do
      term = terms.send(:current_term_hash, Date.new(2018, 3, 23))
      expect(term[:term]).to eq("Winter 2018")
    end

    it "returns the appropriate term on the first day of the quarter" do
      term = terms.send(:current_term_hash, Date.new(2018, 3, 24))
      expect(term[:term]).to eq("Spring 2018")
    end
  end
  describe "future terms" do
    it "returns 2 terms" do
      expect(terms.future_terms.length).to eq(2)
    end

    it "returns the two terms after a particular term" do
      ft = terms.future_terms("Winter 2016")
      expect(ft.length).to eq(2)
      expect(ft).to include("Spring 2016")
      expect(ft).to include("Summer 2016")
    end

    it "handles future terms that split the academic calendar" do
      ft = terms.future_terms("Spring 2016")
      expect(ft.length).to eq(2)
      expect(ft).to include("Summer 2016")
      expect(ft).to include("Fall 2016")
    end

    it "is able to handle when we are at the end of the academic calendar" do
      ft = terms.future_terms("Summer 2016")
      expect(ft.length).to eq(2)
      expect(ft).to include("Fall 2016")
      expect(ft).to include("Winter 2017")
    end

    it "returns 1 term when we are at the end of the list" do
      expect(terms.future_terms("Spring 2027")).to eq(["Summer 2027"])
    end
  end
  describe "processing terms for CourseWork file names" do
    it "handles various terms" do
      expect(terms.process_term_for_cw("Spring 2012")).to eq("Sp12")
      expect(terms.process_term_for_cw("Winter 2013")).to eq("W13")
      expect(terms.process_term_for_cw("Summer 2020")).to eq("Su20")
      expect(terms.process_term_for_cw("Fall 2012")).to eq("F12")
    end

    it "shuld handle all years into the future" do
      expect(terms.process_term_for_cw("Spring 3945")).to eq("Sp45")
    end
  end
end
