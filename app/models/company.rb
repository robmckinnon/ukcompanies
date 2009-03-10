class Company < ActiveRecord::Base

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true

  has_many :lobbyist_clients
  has_many :ogc_suppliers

  def companies_house_url
    @companies_house_url ||= (CompaniesHouse.url_for_number(company_number) || '')
  end

  def companies_house_data
    begin 
      @companies_house_data ||= (CompaniesHouse.search_by_number(company_number) || '')
    rescue Timeout::Error
      # do nothing for the moment
    end
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

  def to_more_xml
    to_xml(:except=>[:id,:created_at,:updated_at]) do |xml|
      xml.ogc_supplier(ogc_suppliers.empty? ? 'no' : 'yes')
      xml.lobbyist_client(lobbyist_clients.empty? ? 'unknown' : 'yes')
      xml.id("http://ukcompani.es/#{friendly_id}")
      xml.short_id("http://ukcompani.es/#{company_number}")
    end.gsub('ogc_supplier','ogc-supplier').gsub('lobbyist_client','lobbyist-client').gsub('short_id','short-id')
  end

end
