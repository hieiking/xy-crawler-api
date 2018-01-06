class ChangeIdToItems < ActiveRecord::Migration[5.1]
  def change
  	change_column :items, :id, :integer
  	change_table :items do |t|
			t.primary_key :id
		end
  end
end
