class Slug < ActiveRecord::Base
  def to_friendly_id
    name
  end
end

class Company < ActiveRecord::Base

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true

  has_many :lobbyist_clients
  has_many :ogc_suppliers

  NUMBER_PATTERN = /([A-Z][A-Z])?(\d)?(\d)?\d\d\d\d\d\d/

  class << self

    def find_all_by_slug(slug)
      Slug.find(:all, :conditions => {:name => slug}).collect(&:sluggable)
    end

    # raises CompaniesHouse::Exception if error
    def retrieve_by_name name
      companies = find_all_by_company_name(name)
      matches = companies.select{|x| x.name[/^#{name}$/i]}

      if matches.empty?
        matches = companies.select{|x| x.name[/^#{name} (group|limited|llp|ltd|plc)$/i]}
        if matches.empty?
          numbers = retrieve_by_name_with_rows name, 20
          companies = numbers.collect do |number|
            logger.info "retrieving #{number}"
            company = retrieve_by_number number
            sleep 0.5
            company
          end.compact
        else
          companies = matches
        end
      else
        companies = matches
      end

      companies
    end

    def retrieve_by_name_with_rows name, rows, numbers = [], last_name=name
      logger.info "retriving #{rows} for #{last_name}"
      results = CompaniesHouse.name_search(last_name, :search_rows => rows)

      if results && results.respond_to?(:co_search_items)
        items = results.co_search_items
        logger.info items.size

        if items.last.company_name[/#{name}/i]
          sleep 0.5
          numbers = numbers + retrieve_by_name_with_rows(name, 100, numbers, items.last.company_name.gsub('&','AND'))
          logger.info "numbers #{numbers.size} for #{last_name}"
        end

        matches = items.select{|item| item.company_name[/#{name}/i]}
        numbers = (matches.collect(&:company_number) + numbers).uniq
      end
      numbers
    end

    def retrieve_by_number number
      company = find_by_company_number(number)
      unless company
        details = CompaniesHouse.company_details(number) # doesn't work between 12am-7am, but number_search does
        if details && details.respond_to?(:company_name)
          company = Company.create({:name => details.company_name,
              :company_number => details.company_number,
              :address => details.reg_address.address_lines.join("\n"),
              :company_status => details.company_status,
              :company_category => details.company_category,
              :incorporation_date => details.incorporation_date,
              :country_code => 'uk'
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
      find(:all, :conditions => %Q|name like "#{name.gsub('"','')}%"|)
    end

    def find_this identifier
      if identifier[Company::NUMBER_PATTERN]
        company = retrieve_by_number(identifier)
      else
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

  def to_more_xml(host='localhost')
    to_xml(:except=>[:id,:created_at,:updated_at]) do |xml|
      xml.ogc_supplier(ogc_suppliers.empty? ? 'no' : 'yes')
      xml.lobbyist_client(lobbyist_clients.empty? ? 'unknown' : 'yes')
      xml.id("http://#{host}/#{country_code}/#{company_number}")
      xml.long_url("http://#{host}/#{country_code}/#{company_number}/#{friendly_id}")
      xml.xml_url("http://#{host}/#{country_code}/#{company_number}.xml")
    end.gsub('ogc_supplier','ogc-supplier').gsub('lobbyist_client','lobbyist-client').gsub('short_id','short-id')
  end

end
