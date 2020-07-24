class AddEditorsReservesIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :editors_reserves, [:reserve_id, :editor_id]
    add_index :editors_reserves, [:editor_id, :reserve_id]
  end
end
