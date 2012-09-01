class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.timestamps
      t.boolean :is_blocked, :default => false	
      t.timestamps
    end
    User.create(:email => 'biz@dealkat.com', :password => 'princessthecat')
  end
end
