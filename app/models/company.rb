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

  NUMBER_PATTERN = /([A-Z][A-Z])?\d\d\d\d(\d)?(\d)?(\d)?(\d)?([A-Z])?([A-Z])?/

  class << self

    def sort_name name
      compare_name(name).sub(/^THE /,'').sub(/\s(\(?HOLDINGS\)?\s)?(\(?G\.?B\.?\)?\s)?(\(?U\.?K\.?\)?\s)?(COMPANY\s)?(GROUP\s)?(LIMITED|LTD|PLC|LLP)\.?$/,'').gsub(/\s(COMPANY|CORPORATION)\s?$/,'').gsub('&','AND').gsub(' - ',' ').tr('"','').tr('-',' ')
    end

    def compare_name name
      name.tr('(','').tr(')','')
    end

    # returns array of [company, score, match] elements
    def single_query term, limit=nil
      term = Search.normalize_term(term)
      if search = Search.find_from_term(term)
        search.reconciliation_results(term, limit)
      else
        numbers_and_names = retrieve_company_numbers_and_names(term)
        if numbers_and_names.empty?
          []
        else
          search = Search.create_from_term(term, numbers_and_names)
          search.reconciliation_results(term, limit)
        end
      end
    end

    # returns hash of keys to array of [company, score, match] elements
    def multiple_query hash
      hash.keys.inject(ActiveSupport::OrderedHash.new) do |results, key|
        term = hash[key]['query']
        limit = hash[key]['limit']

        results[key] = single_query(term, limit)
        results
      end
    end

    def find_all_by_slug(slug)
      Slug.find(:all, :conditions => {:name => slug}).collect(&:sluggable)
    end

    # raises CompaniesHouse::Exception if error
    def retrieve_by_name name
      term = Search.normalize_term(name)
      search = Search.find_from_term(term)

      unless search
        numbers_and_names = retrieve_company_numbers_and_names(term)
        unless numbers_and_names.empty?
          search = Search.create_from_term(term, numbers_and_names)
        end
      end

      search ? search.sorted_companies : []
    end

    def numberfy text
      text = text.gsub('1','one').gsub('2','two').gsub('3','three').gsub('4','four').gsub('5','five').gsub('6','six').gsub('7','seven').gsub('8','eight').gsub('9','nine').gsub('0','o')
      if text[/^(.*) (group|limited|llp|ltd|plc)\.?$/i]
        text = $1
      end
      text
    end

    def retrieve_company_numbers_and_names name, rows=20, numbers_and_names=[], last_name=name
      logger.info "retriving #{rows} for #{last_name}"
      results = CompaniesHouse.name_search(last_name, :search_rows => rows)

      no_space_name = numberfy(name.tr('- .',''))
      alt_name = numberfy(name).gsub(' ','[^A-Z]')

      if results && results.respond_to?(:co_search_items)
        items = results.co_search_items
        logger.info items.size

        if numberfy(items.last.company_name).tr('- .','')[/#{no_space_name}/i]
          sleep 0.5
          numbers_and_names = numbers_and_names + retrieve_company_numbers_and_names(name, 100, numbers_and_names, items.last.company_name.gsub('&','AND'))
          logger.info "numbers #{numbers_and_names.size} for #{last_name}"
        else
          logger.info "no more matches: #{items.last.company_name}"
        end

        matches = items.select{|item| item.company_name[/#{name}/i] || numberfy(item.company_name)[/#{alt_name}/i]}
        matches = matches.collect {|match| [match.company_number.strip, match.company_name.strip] }
        numbers_and_names = (matches + numbers_and_names).uniq
      end
      numbers_and_names.compact.uniq
    end

    def find_from_company_number(number)
      company = find_by_company_number(number)
      if company && company.missing_attributes?
        attributes = attributes_for_number(number)
        company.update_attributes(attributes) if attributes
      end
      company
    end

    def retrieve_by_number number
      logger.info "retrieving #{number}"
      number = number.strip
      company = find_from_company_number(number)
      unless company
        attributes = attributes_for_number(number)
        company = Company.create(attributes) if attributes
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

    def attributes_for_number number
      details = CompaniesHouse.company_details(number)
      if details_match?(details, number)
        attributes_from_details(number, details)
      else
        nil
      end
    end

    def details_match? details, number
      details && details.respond_to?(:company_name) && (number == details.company_number.strip)
    end

    def attributes_from_details company_number, details
      {:name => details.company_name,
       :company_number => company_number,
       :address => address_from_details(details),
       :company_status => details.company_status,
       :company_category => details.company_category,
       :incorporation_date => details.respond_to?(:incorporation_date) ? details.incorporation_date : nil,
       :country_code => 'uk'}
    end

    def address_from_details details
      details.respond_to?(:reg_address) ? ( details.reg_address.respond_to?(:address_lines) ? details.reg_address.address_lines.join("\n") : nil ) : nil
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

  def to_gridworks_hash
    hash = ActiveSupport::OrderedHash.new
    hash[:id] = subject_id
    hash[:name] = name
    hash[:type] = [{ :id => '/organization/organization', :name => 'Organization' }]
    hash
  end

  def subject_indicator(host)
    "http://#{host}#{subject_id}"
  end

  def subject_id
    "/#{country_code}/#{company_number}"
  end

  def missing_attributes?
    company_category.blank?
  end

  def sort_name
    @sort_name ||= Company.sort_name(name)
  end

  def compare_name
    @compare_name ||= Company.compare_name(name)
  end

end
