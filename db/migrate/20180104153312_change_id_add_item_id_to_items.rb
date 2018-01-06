class ChangeIdAddItemIdToItems < ActiveRecord::Migration[5.1]
  def change
  	 change_table :items, id:true do |t|
	  t.string :item_id
	end
  end
end
