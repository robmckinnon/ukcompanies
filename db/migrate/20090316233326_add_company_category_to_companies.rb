class AddCompanyCategoryToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :company_category, :string

    add_index :companies, :company_category
  end

  def self.down
    remove_column :companies, :company_category
  end
end
