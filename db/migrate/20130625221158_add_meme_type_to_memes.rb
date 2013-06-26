class AddMemeTypeToMemes < ActiveRecord::Migration
  def change
    add_column :memes, :meme_type, :string
  end
end
