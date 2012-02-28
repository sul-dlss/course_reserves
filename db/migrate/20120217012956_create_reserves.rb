class CreateReserves < ActiveRecord::Migration
  def up
    create_table :reserves do |t|
      t.string :cid
      t.string :sid
      t.string :desc
      t.string :library
      t.boolean :immediate
      t.string :term
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :instructor_sunet_ids
      t.string :editor_sunet_ids
      t.text :item_list
      t.boolean :has_been_sent

      t.timestamps
    end
  end

  def down
    drop_table :reserves
  end
end

# Item list comprises
# :title
# :ckey
# :comment
# :copies
# :personal
# :purchase
# :loan_period
