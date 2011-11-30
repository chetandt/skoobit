class AddFieldsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :isbn, :string
    add_column :products, :isbn_13, :string
    add_column :products, :image_url, :string
    add_column :products, :price, :string
    add_column :products, :author, :string
    add_column :products, :publisher, :string
  end

  def self.down
  end
end
