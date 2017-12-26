class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items, id: false do |t|
    	t.belongs_to :product, index: true
    	t.string :id, null: false
    	t.string :title, null: false
    	t.integer :price, null: false
    	t.string :desc 
    	t.string :pic_url, null: false

      t.timestamps
    end
  end
end
