class CreateOgcSuppliers < ActiveRecord::Migration
  def self.up
    create_table :ogc_suppliers do |t|
      t.string :name
      t.integer :ogc_id
      t.integer :company_id

      t.timestamps
    end

    add_index :ogc_suppliers, :company_id
  end

  def self.down
    drop_table :ogc_suppliers
  end
end
