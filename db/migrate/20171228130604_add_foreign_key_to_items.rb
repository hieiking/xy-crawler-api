class AddForeignKeyToItems < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :items, :products
  end
end
