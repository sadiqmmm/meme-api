class CreateMemes < ActiveRecord::Migration
  def change
    create_table :memes do |t|
      t.string :type
      t.string :top
      t.string :bottom
      t.string :link
      t.integer :user_id

      t.timestamps
    end
  end
end
