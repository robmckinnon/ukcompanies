class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string :term

      t.timestamps
    end

    add_index :searches, :term
  end

  def self.down
    remove_index :searches, :term

    drop_table :searches
  end
end
