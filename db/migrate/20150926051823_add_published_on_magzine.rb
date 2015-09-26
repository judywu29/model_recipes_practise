class AddPublishedOnMagzine < ActiveRecord::Migration
  def change
    add_column :magzines, :published, :boolean
  end
end
