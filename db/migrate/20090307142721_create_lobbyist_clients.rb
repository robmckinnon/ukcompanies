class CreateLobbyistClients < ActiveRecord::Migration
  def self.up
    create_table :lobbyist_clients do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end

    add_index :lobbyist_clients, :company_id
  end

  def self.down
    drop_table :lobbyist_clients
  end
end
