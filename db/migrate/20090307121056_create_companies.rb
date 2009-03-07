class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name
      t.string :company_number
      t.text :address
      t.string :url
      t.string :wikipedia_url

      t.timestamps
    end

    add_index :companies, :company_number
    add_index :companies, :name
    add_index :companies, :url
  end

  def self.down
    drop_table :companies
  end
end
