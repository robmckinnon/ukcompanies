class AddStatusAndIncorporationDateToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :company_status, :string
    add_column :companies, :incorporation_date, :date

    add_index :companies, :company_status
  end

  def self.down
    remove_column :companies, :company_status
    remove_column :companies, :incorporation_date
  end
end
