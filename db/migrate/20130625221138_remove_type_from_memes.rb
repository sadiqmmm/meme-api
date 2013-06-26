class RemoveTypeFromMemes < ActiveRecord::Migration
  def change
    remove_column :memes, :type, :string
  end
end
