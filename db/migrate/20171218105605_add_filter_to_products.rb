class AddFilterToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :filter, :text
  end
end
