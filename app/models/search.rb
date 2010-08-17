class Search < ActiveRecord::Base

  has_many :search_results, :dependent => :delete_all

  has_many :companies, :through => :search_results, :source => :company

  validates_uniqueness_of :term

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
