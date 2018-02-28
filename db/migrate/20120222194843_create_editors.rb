class CreateEditors < ActiveRecord::Migration[4.2]
  def change
    create_table :editors do |t|
      t.string :sunetid

      t.timestamps
    end
  end
end
