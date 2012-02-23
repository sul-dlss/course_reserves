require 'spec_helper'

describe Reserve do
  
  describe "editor relationships" do
    
    it "should add an editor relationship" do
      reserve = Reserve.create( { :editors => [Editor.create({:sunetid => 'test'})], :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve.editors.length.should==1
      reserve.editors.first[:sunetid].should=='test'     
    end
    
  end

  describe "item_list serialization" do 
    it "should serialize the item list" do 
      reserve = Reserve.create( { :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve[:item_list].should == [{ :title => 'My Title' }]
    end 
    
    it "should throw an error for TypeMismatch when we serialize the item list with a hash" do 
      lambda {Reserve.create( { :cid => 'test_cid', :item_list => { :title => 'My Title' } } )}.should raise_error(ActiveRecord::SerializationTypeMismatch)
    end 

  end
end
