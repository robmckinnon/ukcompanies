class CreateSearchResults < ActiveRecord::Migration
  def self.up
    create_table :search_results do |t|
      t.integer :search_id
      t.integer :company_id
    end

    add_index :search_results, :search_id
    add_index :search_results, :company_id
  end

  def self.down
    remove_index :search_results, :search_id
    remove_index :search_results, :company_id

    drop_table :search_results
  end
end
