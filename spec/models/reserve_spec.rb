require 'rails_helper'

RSpec.describe Reserve do
  let(:reserve_params) do
    {:library => "Green", :term=>Terms.current_term, :contact_name => "John Doe", :contact_phone=>"(555)555-5555", :contact_email=>"jdoe@example.com"}
  end

  describe '#course' do
    it 'fetches a course from the reserve compound_key' do
      expect(Reserve.new(compound_key: 'AA-272C,123,456').course[:cid]).to eq 'AA-272C'
    end
  end

  describe "editor relationships" do

    it "should generate editor relationships from editor_sunet_ids field for single sunet_id" do
      reserve = Reserve.create( reserve_params.merge({ :editor_sunet_ids => 'jlavigne', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] }) )
      reserve.save!
      expect(reserve.editors.length).to eq(1)
      expect(reserve.editors.first[:sunetid]).to eq('jlavigne')
    end

    it "should generate editor relationships from editor_sunet_ids field for multiple sunet_id" do
      reserve = Reserve.create( reserve_params.merge({ :editor_sunet_ids => 'jlavigne, jkeck', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] }) )
      reserve.save!
      expect(reserve.editors.length).to eq(2)
      editors = reserve.editors.map{|e| e[:sunetid] }
      expect(editors.include?('jlavigne')).to eq(true)
      expect(editors.include?('jkeck')).to eq(true)
    end

    it "should generate editor relationships from instructor_sunet_ids field for single sunet_id" do
      reserve = Reserve.create( reserve_params.merge({ :instructor_sunet_ids => 'asmith', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] }) )
      reserve.save!
      expect(reserve.editors.length).to eq(1)
      expect(reserve.editors.first[:sunetid]).to eq('asmith')
    end

    it "should generate editor relationships from instructor_sunet_ids field for multiple sunet_ids" do
      reserve = Reserve.create( reserve_params.merge({ :instructor_sunet_ids => 'jlavigne, jkeck', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] }) )
      reserve.save!
      expect(reserve.editors.length).to eq(2)
      editors = reserve.editors.map{|e| e[:sunetid] }
      expect(editors.include?('jlavigne')).to eq(true)
      expect(editors.include?('jkeck')).to eq(true)
    end

    it "should udpated editors when we save an item too." do
      res = Reserve.create(reserve_params.merge({:instructor_sunet_ids=>'jkeck'}))
      res.save!
      expect(Reserve.find(res[:id]).editors.length).to eq(1)
      upd_res = Reserve.update(res[:id], reserve_params.merge({:instructor_sunet_ids=>'jkeck, jlavigne'}))
      upd_res.save!
      expect(Reserve.find(res[:id]).editors.length).to eq(2)
    end

    it "should generate editor relationships from instructor_sunet_ids & editor_sunet_ids fields for multiple sunet_ids" do
      reserve = Reserve.create( reserve_params.merge({ :editor_sunet_ids => 'asmith, bjones', :instructor_sunet_ids => 'jlavigne, jkeck', :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] }) )
      reserve.save!
      expect(reserve.editors.length).to eq(4)
      editors = reserve.editors.map{|e| e[:sunetid] }
      expect(editors).to eq(['jlavigne', 'jkeck', 'asmith', 'bjones'])
    end

    it "should remove editor relationship when we remove a SUNet ID from the list" do
      res = Reserve.create(reserve_params.merge({:instructor_sunet_ids=>'jkeck, jlavigne'}))
      res.save!
      expect(res.editors.length).to eq(2)
      expect(Editor.find_by_sunetid("jlavigne").reserves.length).to eq(1)
      upd_res = Reserve.update(res[:id], reserve_params.merge({:instructor_sunet_ids=>'jkeck'}))
      upd_res.save!
      new_res = Reserve.find(res[:id])
      expect(new_res.editors.length).to eq(1)
      expect(Editor.find_by_sunetid("jlavigne").reserves).to be_blank
    end

  end

  describe "item_list serialization" do
    it "should serialize the item list" do
      reserve = Reserve.create( reserve_params.merge({ :cid => 'test_cid', :item_list => [{ :title => 'My Title' }] }) )
      reserve.save!
      expect(reserve[:item_list].first[:title]).to eq('My Title')
    end

    it "should throw an error for TypeMismatch when we serialize the item list with a hash" do
      expect {Reserve.create( reserve_params.merge({ :cid => 'test_cid', :item_list => { :title => 'My Title' } }) )}.to raise_error(ActiveRecord::SerializationTypeMismatch)
    end

  end
end
