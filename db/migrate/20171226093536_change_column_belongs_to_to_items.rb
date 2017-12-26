class ChangeColumnBelongsToToItems < ActiveRecord::Migration[5.1]
  def change
  	# change_column :items, :belongs_to, autosave: true
  	change_table :items do |t|
	  t.belongs_to :products, autosave: true
	end
  end

end
