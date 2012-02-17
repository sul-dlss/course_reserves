require 'spec_helper'

describe Reserve do

  describe "item_list serialization" do 
    it "should serialize the item list" do 
      reserve = Reserve.new( { :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve[:item_list].should == [{ :title => 'My Title' }]
    end 
    
    it "should throw an error for TypeMismatch when we serialize the item list with a hash" do 
      reserve = Reserve.new( { :cid => 'test_cid', :item_list => { :title => 'My Title' } } )
      lambda {reserve.save!}.should raise_error(ActiveRecord::SerializationTypeMismatch)
    end 

  end
end
