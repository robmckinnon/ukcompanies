class AddLogoImageUrlToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :logo_image_url, :string
  end

  def self.down
    remove_column :companies, :logo_image_url, :string
  end
end
