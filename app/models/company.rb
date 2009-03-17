class Slug < ActiveRecord::Base
  def to_friendly_id
    name
  end
end

class Company < ActiveRecord::Base

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true

  has_many :lobbyist_clients
  has_many :ogc_suppliers

  class << self

    def retrieve_by_name name
      companies = find_all_by_company_name(name)
      if companies.empty?
        results = CompaniesHouse.name_search(name)

        if results && results.respond_to?(:co_search_items)
          items = results.co_search_items
          matches = items.select{|item| item.company_name[/#{name}/i]}
          numbers = matches.collect(&:company_number)
          companies = numbers.collect do |number|
            company = retrieve_by_number number
            sleep 0.5
            company
          end.compact
        end
      end
      companies
    end

    def retrieve_by_number number
      company = find_by_company_number(number)
      unless company
        details = CompaniesHouse.company_details(number)

        if details && details.respond_to?(:company_name)
          company = Company.create({:name => details.company_name,
              :company_number => details.company_number,
              :address => details.reg_address.address_lines.join("\n"),
              :company_status => details.company_status,
              :company_category => details.company_category,
              :incorporation_date => details.incorporation_date
          })
        end
      end
      company
    end

    def name_search name
      results = CompaniesHouse.name_search(name)
      results
    end

    def find_all_by_company_name name
      find(:all, :conditions => %Q|name like "%#{name.gsub('"','')}%"|)
    end

    def find_this identifier
      company = retrieve_by_number(identifier)
      unless company
        company = find(identifier)
      end
      company
    end
  end

  def companies_house_url
    @companies_house_url ||= (AltCompaniesHouse.url_for_number(company_number) || '')
  end

  def companies_house_data
    begin
      @companies_house_data ||= (AltCompaniesHouse.search_by_number(company_number) || '')
    rescue Timeout::Error
      # do nothing for the moment
    end
  end

  def find_company_data
    data = AltCompaniesHouse.search_by_name(name)
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
