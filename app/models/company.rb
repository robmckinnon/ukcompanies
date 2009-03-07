class Company < ActiveRecord::Base

  has_many :lobbyist_clients
  has_many :ogc_suppliers


end
