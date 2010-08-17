class Search < ActiveRecord::Base

  has_many :search_results, :dependent => :delete_all

  has_many :companies, :through => :search_results, :source => :company

  validates_uniqueness_of :term

  class << self
    def normalize_term term
      term = term.squeeze(' ')
      term = "#{term} " if term.size < 4 && !term.ends_with?(' ')
      term
    end

    def find_from_term term
      search = find_by_term(term, :include => :companies)
      if search && search.term == term
        search
      else
        nil
      end
    end

    def create_from_term term, company_numbers_and_names
      search = Search.new :term => term
      if company_numbers_and_names.size == 1
        company_number = company_numbers_and_names.first.first
        company = Company.retrieve_by_number(company_number)
        search.search_results.build(:company_id => company.id) if company
      else
        company_numbers_and_names.each do |company_number, name|
          company = Company.find_or_create_by_company_number_and_name_and_country_code(company_number, name, 'uk')
          search.search_results.build(:company_id => company.id) if company
        end
      end
      search.save
      search
    end
  end

  def reconciliation_results(term, limit)
    results = limit ? companies.first(limit.to_i) : companies

    results.collect do |company|
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

  private
    def accuracy_score numerator, denominator
      (( (numerator * 100.0) / denominator) * 100 ).to_i / 100.0
    end
end
