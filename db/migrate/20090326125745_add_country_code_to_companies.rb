class AddCountryCodeToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :country_code, :string, :limit => 2
  end

  def self.down
    remove_column :companies, :country_code
  end
end
