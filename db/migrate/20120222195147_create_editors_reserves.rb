class CreateEditorsReserves < ActiveRecord::Migration[4.2]
  def up
    
    create_table :editors_reserves, :id => false do |t|
      
      t.references :editor     
      t.references :reserve
      
    end
    
  end

  def down
  
    drop_table :editors_reserves  
  
  end
end
