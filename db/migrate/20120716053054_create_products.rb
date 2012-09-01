class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.string :author
      t.integer :product_type
      t.integer :quantity, :default => 1
      t.float :regular_price
      t.float :target_price	
      t.timestamps
    end
    add_attachment :products,:image
  end
end
