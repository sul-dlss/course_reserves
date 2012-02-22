class CreateReservesEditors < ActiveRecord::Migration
  def up
    
    create_table :reserves_editors, :id => false do |t|
      
      t.references :reserve
      t.references :editor
      
    end
    
  end

  def down
  
    drop_table :reserves_editors  
  
  end
end
