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
    
    it "should generate editor relationships from instructor_sunet_ids field for single sunet_id" do
      reserve = Reserve.create( { :instructor_sunet_ids => 'asmith', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve.editors.length.should==1
      reserve.editors.first[:sunetid].should=='asmith'   
    end
    
    it "should generate editor relationships from instructor_sunet_ids field for multiple sunet_ids" do
      reserve = Reserve.create( { :instructor_sunet_ids => 'jlavigne, jkeck', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve.editors.length.should==2
      editors = reserve.editors.map{|e| e[:sunetid] }
      editors.include?('jlavigne').should==true
      editors.include?('jkeck').should==true
    end
    
    it "should udpated editors when we save an item too." do
      res = Reserve.create({:instructor_sunet_ids=>'jkeck'})
      res.save!
      Reserve.find(res[:id]).editors.length.should == 1
      upd_res = Reserve.update(res[:id], {:instructor_sunet_ids=>'jkeck, jlavigne'})
      upd_res.save!
      Reserve.find(res[:id]).editors.length.should == 2
    end
    
    it "should generate editor relationships from instructor_sunet_ids & editor_sunet_ids fields for multiple sunet_ids" do
      reserve = Reserve.create( { :editor_sunet_ids => 'asmith, bjones', :instructor_sunet_ids => 'jlavigne, jkeck', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] } )
      reserve.save!
      reserve.editors.length.should==4
      editors = reserve.editors.map{|e| e[:sunetid] }
      editors.should==['jlavigne', 'jkeck', 'asmith', 'bjones']
    end
    
    it "should remove editor relationship when we remove a SUNet ID from the list" do
      res = Reserve.create({:instructor_sunet_ids=>'jkeck, jlavigne'})
      res.save!
      res.editors.length.should == 2
      Editor.find_by_sunetid("jlavigne").reserves.length.should == 1
      upd_res = Reserve.update(res[:id], {:instructor_sunet_ids=>'jkeck'})
      upd_res.save!
      new_res = Reserve.find(res[:id])
      new_res.editors.length.should == 1
      Editor.find_by_sunetid("jlavigne").reserves.should be_blank
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
