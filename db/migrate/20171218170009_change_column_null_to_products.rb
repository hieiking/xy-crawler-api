class ChangeColumnNullToProducts < ActiveRecord::Migration[5.1]
  def change
  	change_column_null :products, :record_ids, true

	change_table :products do |t|
	  t.rename :product_name, :name
	end
  end
end
