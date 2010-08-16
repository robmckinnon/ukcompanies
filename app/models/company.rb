class Slug < ActiveRecord::Base
  def to_friendly_id
    name
  end
end

class Company < ActiveRecord::Base

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true

  has_many :lobbyist_clients
  has_many :ogc_suppliers

  validates_uniqueness_of :company_number

  NUMBER_PATTERN = /([A-Z][A-Z])?(\d)?(\d)?\d\d\d\d\d\d/

  class << self

    # returns array of [company, score, match] elements
    def single_query hash
      term = hash['query']
      limit = hash['limit']
      search = Search.find_by_term(term, :include => :companies)
      companies = if search
        if limit
          search.companies.first(limit.to_i)
        else
          search.companies
        end
      else
        []
      end

      companies.collect do |company|
        is_match = false
        score = if term.size < company.name.size
          accuracy_score(term.size, company.name.size)
        else
          accuracy_score(0.9, companies.size)
        end

        if (companies.size == 1) && (companies.first.name.downcase.strip == term.downcase.strip)
          is_match = true
          score = 90.0
        end

        [company, score, is_match]
      end
    end

    # returns hash of keys to array of [company, score, match] elements
    def multiple_query hash
      results = ActiveSupport::OrderedHash.new
      hash.keys.each do |key|
        query = hash[key]
        companies = single_query(query)
        results[key] = companies
      end
      results
    end

    def find_all_by_slug(slug)
      Slug.find(:all, :conditions => {:name => slug}).collect(&:sluggable)
    end

    # raises CompaniesHouse::Exception if error
    def retrieve_by_name name
      term = name.squeeze(' ')
      term = "#{term} " if term.size < 4 && !term.ends_with?(' ')
      search = Search.find_by_term(term, :include => :companies)

      if search && search.term == term
        companies = search.companies
      else
        company_numbers = retrieve_company_numbers_by_name_with_rows(term, 20)
        if company_numbers.empty?
          companies = []
        else
          search = Search.new :term => term
          companies = company_numbers.collect do |number|
            logger.info "retrieving #{number}"
            company = retrieve_by_number(number)
            if company
              search.search_results.build(:company_id => company.id)
            end
            company
          end
          companies.compact!
          search.save unless companies.empty?
        end
      end

      companies
    end

    def numberfy text
      text = text.gsub('1','one').gsub('2','two').gsub('3','three').gsub('4','four').gsub('5','five').gsub('6','six').gsub('7','seven').gsub('8','eight').gsub('9','nine').gsub('0','o')
      if text[/^(.*) (group|limited|llp|ltd|plc)\.?$/i]
        text = $1
      end
      text
    end

    def retrieve_company_numbers_by_name_with_rows name, rows, company_numbers = [], last_name=name
      logger.info "retriving #{rows} for #{last_name}"
      results = CompaniesHouse.name_search(last_name, :search_rows => rows)

      no_space_name = numberfy(name.tr('- .',''))
      alt_name = numberfy(name).gsub(' ','[^A-Z]')

      if results && results.respond_to?(:co_search_items)
        items = results.co_search_items
        logger.info items.size

        if numberfy(items.last.company_name).tr('- .','')[/#{no_space_name}/i]
          sleep 0.5
          company_numbers = company_numbers + retrieve_company_numbers_by_name_with_rows(name, 100, company_numbers, items.last.company_name.gsub('&','AND'))
          logger.info "numbers #{company_numbers.size} for #{last_name}"
        else
          logger.info "no more matches: #{items.last.company_name}"
        end

        matches = items.select{|item| item.company_name[/#{name}/i] || numberfy(item.company_name)[/#{alt_name}/i]}
        company_numbers = (matches.collect(&:company_number) + company_numbers).uniq
      end
      company_numbers.compact.uniq
    end

    def retrieve_by_number number
      number = number.strip
      company = find_by_company_number(number)
      unless company
        details = CompaniesHouse.company_details(number) # doesn't work between 12am-7am, but number_search does
        sleep 0.5
        if details && details.respond_to?(:company_name)
          company_number = details.company_number.strip
          if number == company_number
            company = Company.create({:name => details.company_name,
                :company_number => company_number,
                :address => details.respond_to?(:reg_address) ? ( details.reg_address.respond_to?(:address_lines) ? details.reg_address.address_lines.join("\n") : nil ) : nil,
                :company_status => details.company_status,
                :company_category => details.company_category,
                :incorporation_date => details.respond_to?(:incorporation_date) ? details.incorporation_date : nil,
                :country_code => 'uk'
            })
          end
        end
      end
      company
    end

    def name_search name
      results = CompaniesHouse.name_search(name)
      results
    end

    def find_all_by_company_name name
      find(:all, :conditions => ['name like ?', %Q|#{name.gsub('"','')}%|]) +
        find(:all, :conditions => ['name like ?', %Q|The #{name.gsub('"','')}%|])
    end

    def find_this identifier
      if identifier[Company::NUMBER_PATTERN]
        company = retrieve_by_number(identifier)
      else
        company = find(identifier)
      end
      company
    end

    private
    def accuracy_score numerator, denominator
      (( (numerator * 100.0) / denominator) * 100 ).to_i / 100.0
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
      xml.id(subject_indicator(host))
      xml.long_url("#{subject_indicator(host)}/#{friendly_id}")
      xml.xml_url("#{subject_indicator(host)}.xml")
    end.gsub('ogc_supplier','ogc-supplier').gsub('lobbyist_client','lobbyist-client').gsub('short_id','short-id')
  end

  def to_gridworks_hash(host='localhost')
    hash = ActiveSupport::OrderedHash.new
    hash[:id] = subject_indicator(host)
    hash[:name] = name
    hash[:type] = [{ :id => '/organization/organization', :name => 'Organization' }]
    hash
  end

  def subject_indicator(host)
    "http://#{host}/#{country_code}/#{company_number}"
  end

end
