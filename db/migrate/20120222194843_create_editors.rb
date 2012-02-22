class CreateEditors < ActiveRecord::Migration
  def change
    create_table :editors do |t|
      t.string :sunetid

      t.timestamps
    end
  end
end
