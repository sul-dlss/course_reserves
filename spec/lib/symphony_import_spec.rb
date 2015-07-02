require 'spec_helper'
require "symphony_import"

class SI_Class
end

def test_file_path
  return "#{Rails.root}/spec/fixtures/symphony_import_test.txt"
end
  


describe "SymphonyImport" do
  
  before(:each) do
    @si_class = SI_Class.new
    @si_class.extend(SymphonyImport)
  end
  
  
  describe "parsing an entry line and getting back a key and hash" do
    it "should take an entry line and return a key and hash of entry elements" do
      entry_key, entry_hash = @si_class.get_entry_hash_and_key('GREEN-RESV|20120323|CURRENT|8634|36105011709016  |STACKS|GREEN-RESV|ON_RESERVE|White collar; the American middle classes|2H|20120323|ACTIVE|AMSTUD-160|Perspectives on American Identity|WINTER|2555460971|01157452|Gillam, Richard A|RGILLAM|rgillam@stanford.edu|(650) 723-4965|')
      expect(entry_key).to eq('AMSTUD-160-rgillam')
      expect(entry_hash[:ckey]).to eq('8634')
      #entry_hash[:ckey].should=={:reserve_desk=>"GREEN-RESV", :resctl_expire_date=>"20120323", :resctl_status=>"CURRENT", :ckey=>"8634", :barcode=>"36105011709016  ", :home_location=>"STACKS", :current_location=>"GREEN-RESV", :item_reserve_status=>"ON_RESERVE", :loan_period=>"2H", :reserve_expire_date=>"20120323", :reserve_stage=>"ACTIVE", :course_id=>"AMSTUD-160", :course_name=>"Perspectives on American Identity", :term=>"WINTER", :instructor_lib_id=>"2555460971", :instructor_univ_id=>"01157452", :instructor_name=>"Gillam, Richard A", :instructor_sunet_id=>"rgillam", :item_title=>"White collar; the American middle classes."}
    end
  end
  
  describe "adding an entry to an empty courses hash" do
    it "should take the courses hash, a key, and a fields hash and return the courses hash with an entry added" do
      courses = {}
      key = 'AMSTUD-160-rgillam'
      fields_hash ={:reserve_desk=>"GREEN-RESV", :resctl_expire_date=>"20120323", :loan_period=>"2H", :course_id=>"AMSTUD-160", :course_name=>"Perspectives on American Identity", :term=>"WINTER", :instructor_lib_id=>"2555460971", :instructor_univ_id=>"01157452", :instructor_name=>"Gillam, Richard A", :instructor_sunet_id=>"rgillam", :item_title=>"White collar; the American middle classes."} 
      courses = @si_class.add_to_courses( courses, key, fields_hash )
      expect(courses.length).to eq(1)
      expect(courses).to have_key("AMSTUD-160-rgillam")
    end
  end
  
  describe "adding an entry to a courses hash that contains an entry" do
    it "should take the courses hash, a key, and a fields hash and return the courses hash with an entry added" do
      courses = {"AMSTUD-160-rgillam"=>{:course_id=>"AMSTUD-160", :course_name=>"Perspectives on American Identity", :instructor_id=>"rgillam"}}
      key = 'AMSTUD-114N-rgillam'
      fields_hash ={:reserve_desk=>"GREEN-RESV", :resctl_expire_date=>"20120323", :loan_period=>"2H", :course_id=>"AMSTUD-114N", :course_name=>"The American 1960s: Thought, Protest, and Culture", :term=>"WINTER", :instructor_lib_id=>"2555460971", :instructor_univ_id=>"01157452", :instructor_name=>"Gillam, Richard A", :instructor_sunet_id=>"rgillam", :item_title=>"Why we can't wait"} 
      courses = @si_class.add_to_courses( courses, key, fields_hash )
      expect(courses.length).to eq(2)
      expect(courses).to have_key("AMSTUD-160-rgillam")
      expect(courses).to have_key("AMSTUD-114N-rgillam")
    end
  end

  
  describe "adding twelve reserves records" do
    it "should take a file path and call the process_import_file method to add twelve records to the database" do
      #courses = @si_class.process_import_file(test_file_path)
      @si_class.process_import_file(test_file_path)
      expect(Reserve.all.length).to eq(12)
      expect(Reserve.find_by_cid("CLASSHIS-114").cid).to eq('CLASSHIS-114')
      expect(Reserve.find_by_cid("CLASSHIS-114")[:item_list].length).to eq(1)
      expect(Reserve.find_by_cid("CLASSHIS-114")[:item_list][0]["ckey"]).to eq('32837')
      expect(Reserve.find_by_cid("HISTORY-273G")[:item_list].length).to eq(4)
      expect(Reserve.find_by_cid("HISTORY-273G")[:item_list][2]["ckey"]).to eq('9247690')
      expect(Reserve.find_by_cid("EDUC-237X").sid).to eq('01')
      # Following to test sorting by title in item list
      expect(Reserve.find_by_cid("HISTORY-273G")[:item_list][3]["title"]).to match(/^The golden age/)
      expect(Reserve.find_by_cid("EDUC-237X").compound_key).to eq('AFRICAAM-165E,EDUC-237X,ETHICSOC-165E,123,456')
      expect(Reserve.find_by_cid("EDUC-237X").cross_listings).to eq('ETHICSOC-165E, AFRICAAM-165E')
      expect(Reserve.find_by_cid("GES-55Q")[:item_list].first["loan_period"]).to eq('3 days')
      #courses.each do |k,v|
      #  puts v.inspect
      #  puts '<br>===================<br>'
      #end
    end    
  end
  
  
  
  
end
