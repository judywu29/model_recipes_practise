class CreateMagzines < ActiveRecord::Migration
  def change
    create_table :magzines do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
