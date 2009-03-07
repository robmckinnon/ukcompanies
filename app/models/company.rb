class Company < ActiveRecord::Base

  has_many :lobbyist_clients
  has_many :ogc_suppliers


  class << self
    def find_all_by_company_name name
      find(:all, :conditions => %Q|name like "%#{name.gsub('"','')}%"|)
    end

    def find_by_company_name name
      find(:first, :conditions => %Q|name like "%#{name.gsub('"','')}%"|)
    end
    
  end
end
