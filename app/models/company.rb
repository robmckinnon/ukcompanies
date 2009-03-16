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
    def name_search name
      results = CompaniesHouse.name_search(name)
      results
    end

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

  def find_company_data
    data = CompaniesHouse.search_by_name(name)
  end

  def to_more_xml
    to_xml(:except=>[:id,:created_at,:updated_at]) do |xml|
      xml.ogc_supplier(ogc_suppliers.empty? ? 'no' : 'yes')
      xml.lobbyist_client(lobbyist_clients.empty? ? 'unknown' : 'yes')
      xml.id("http://ukcompani.es/#{company_number}")
      xml.long_url("http://ukcompani.es/#{company_number}/#{friendly_id}")
      xml.xml_url("http://ukcompani.es/#{company_number}.xml")
    end.gsub('ogc_supplier','ogc-supplier').gsub('lobbyist_client','lobbyist-client').gsub('short_id','short-id')
  end

end
