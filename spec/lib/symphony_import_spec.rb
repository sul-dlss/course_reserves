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
      entry_key.should=='AMSTUD-160-rgillam'
      entry_hash[:ckey].should=='8634'
      #entry_hash[:ckey].should=={:reserve_desk=>"GREEN-RESV", :resctl_expire_date=>"20120323", :resctl_status=>"CURRENT", :ckey=>"8634", :barcode=>"36105011709016  ", :home_location=>"STACKS", :current_location=>"GREEN-RESV", :item_reserve_status=>"ON_RESERVE", :loan_period=>"2H", :reserve_expire_date=>"20120323", :reserve_stage=>"ACTIVE", :course_id=>"AMSTUD-160", :course_name=>"Perspectives on American Identity", :term=>"WINTER", :instructor_lib_id=>"2555460971", :instructor_univ_id=>"01157452", :instructor_name=>"Gillam, Richard A", :instructor_sunet_id=>"rgillam", :item_title=>"White collar; the American middle classes."}
    end
  end
  
  describe "adding an entry to an empty courses hash" do
    it "should take the courses hash, a key, and a fields hash and return the courses hash with an entry added" do
      courses = {}
      key = 'AMSTUD-160-rgillam'
      fields_hash ={:reserve_desk=>"GREEN-RESV", :resctl_expire_date=>"20120323", :loan_period=>"2H", :course_id=>"AMSTUD-160", :course_name=>"Perspectives on American Identity", :term=>"WINTER", :instructor_lib_id=>"2555460971", :instructor_univ_id=>"01157452", :instructor_name=>"Gillam, Richard A", :instructor_sunet_id=>"rgillam", :item_title=>"White collar; the American middle classes."} 
      courses = @si_class.add_to_courses( courses, key, fields_hash )
      courses.length.should == 1
      courses.has_key?("AMSTUD-160-rgillam").should be_true
    end
  end
  
  describe "adding an entry to a courses hash that contains an entry" do
    it "should take the courses hash, a key, and a fields hash and return the courses hash with an entry added" do
      courses = {"AMSTUD-160-rgillam"=>{:course_id=>"AMSTUD-160", :course_name=>"Perspectives on American Identity", :instructor_id=>"rgillam"}}
      key = 'AMSTUD-114N-rgillam'
      fields_hash ={:reserve_desk=>"GREEN-RESV", :resctl_expire_date=>"20120323", :loan_period=>"2H", :course_id=>"AMSTUD-114N", :course_name=>"The American 1960s: Thought, Protest, and Culture", :term=>"WINTER", :instructor_lib_id=>"2555460971", :instructor_univ_id=>"01157452", :instructor_name=>"Gillam, Richard A", :instructor_sunet_id=>"rgillam", :item_title=>"Why we can't wait"} 
      courses = @si_class.add_to_courses( courses, key, fields_hash )
      courses.length.should == 2
      courses.has_key?("AMSTUD-160-rgillam").should be_true
      courses.has_key?("AMSTUD-114N-rgillam").should be_true
    end
  end
  
  
  describe "adding eleven reserves records" do
    it "should take a file path and call the process_import_file method to add eleven records to the database" do
      #courses = @si_class.process_import_file(test_file_path)
      @si_class.process_import_file(test_file_path)
      Reserve.all.length.should==11
      Reserve.find_by_cid("CLASSHIS-114").cid.should=='CLASSHIS-114'
      Reserve.find_by_cid("CLASSHIS-114")[:item_list].length.should==1
      Reserve.find_by_cid("CLASSHIS-114")[:item_list][0][:ckey].should=='32837'
      Reserve.find_by_cid("HISTORY-273G")[:item_list].length.should==4
      Reserve.find_by_cid("HISTORY-273G")[:item_list][2][:ckey].should=='9247690'
      #courses.each do |k,v|
      #  puts v.inspect
      #  puts '<br>===================<br>'
      #end
    end    
  end
  
  
  
  
end