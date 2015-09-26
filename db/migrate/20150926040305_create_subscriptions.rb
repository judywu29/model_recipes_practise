class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.date :last_renewal_on
      t.integer :length_in_issues
      t.belongs_to :reader
      t.belongs_to :magzine

      t.timestamps null: false
    end
  end
end
