class Search < ActiveRecord::Base

  has_many :search_results, :dependent => :delete_all

  has_many :companies, :through => :search_results, :source => :company

  validates_uniqueness_of :term

  class << self
    def normalize_term term
      term = term.squeeze(' ')
      term.gsub!(' & ',' AND ')
      term = "#{term} " if term.size < 4 && !term.ends_with?(' ')
      term
    end

    def find_from_term term
      search = find_by_term(term, :include =>  {:companies => :slugs})
      if search && search.term == term
        search
      else
        nil
      end
    end

    def create_from_term term, company_numbers_and_names
      companies = create_companies(term, company_numbers_and_names)
      create_from_companies(term, companies)
    end

    def create_from_companies term, companies
      search = Search.new :term => term
      companies.each do |company|
        search.search_results.build(:company_id => company.id) if company
      end
      search.save
      search
    end

    def create_companies term, company_numbers_and_names
      if company_numbers_and_names.size == 1
        company_number = company_numbers_and_names.first.first
        [Company.retrieve_by_number(company_number)]
      else
        companies = company_numbers_and_names.collect do |company_number, name|
          if term.strip.size > 5 || Company.sort_name(name)[/^#{term.strip}$/i] || Company.sort_name(name)[/^#{term.strip} /i]
            Company.find_or_create_by_company_number_and_name_and_country_code(company_number, name, 'uk')
          end
        end.compact
      end
    end
  end

  def age_in_days
    (Time.now - updated_at).to_f / 1.day.seconds
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

  def sorted_companies
    companies.sort do |a,b|
      a_name = a.sort_name
      b_name = b.sort_name
      if a_name[/^#{term}/i] && !b_name[/^#{term}/i]
        -1
      elsif !a_name[/^#{term}/i] && b_name[/^#{term}/i]
        1
      else
        comparison = a_name <=> b_name
        if comparison == 0
          comparison = a.compare_name <=> b.compare_name
          if comparison == 0
            a.name <=> b.name
          else
            comparison
          end
        else
          comparison
        end
      end
    end
  end

  private

    def accuracy_score numerator, denominator
      (( (numerator * 100.0) / denominator) * 100 ).to_i / 100.0
    end
end
