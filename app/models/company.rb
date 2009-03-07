class Company < ActiveRecord::Base

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true

  has_many :lobbyist_clients
  has_many :ogc_suppliers
  
  def companies_house_url
    @companies_house_url ||= (CompaniesHouse.url_for_number(company_number) || '')
  end

  class << self
    def find_all_by_company_name name
      find(:all, :conditions => %Q|name like "%#{name.gsub('"','')}%"|)
    end

    def find_this identifier
      company = find_by_company_number(identifier)
      unless company
        company = find(identifier)
      end
      company
    end

  end

    def object_url format=nil
      url_for :controller=>"companies", :action=>"show", :id => friendly_id, :format => format, :only_path => false
    end
end
