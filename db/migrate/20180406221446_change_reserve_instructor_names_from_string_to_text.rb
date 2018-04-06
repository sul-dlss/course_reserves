class ChangeReserveInstructorNamesFromStringToText < ActiveRecord::Migration[5.2]
  def change
    change_column :reserves, :instructor_names, :text
    change_column :reserves, :instructor_sunet_ids, :text
  end

  def down
    # No-op
    # We don't want to change back to string because
    # it can cause issues with strings over 255 chars
  end
end
