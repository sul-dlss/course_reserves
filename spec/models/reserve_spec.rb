require 'spec_helper'

describe Reserve do
  
  describe "editor relationships" do    
    
    it "should generate editor relationships from editor_sunet_ids field for single sunet_id" do
      reserve = Reserve.create( { :editor_sunet_ids => 'jlavigne', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve.editors.length.should==1
      reserve.editors.first[:sunetid].should=='jlavigne'   
    end
    
    it "should generate editor relationships from editor_sunet_ids field for multiple sunet_id" do
      reserve = Reserve.create( { :editor_sunet_ids => 'jlavigne, jkeck', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve.editors.length.should==2
      editors = reserve.editors.map{|e| e[:sunetid] }
      editors.include?('jlavigne').should==true
      editors.include?('jkeck').should==true
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
