class OgcSupplier < ActiveRecord::Base

  belongs_to :company

  validates_presence_of :name
  validates_presence_of :ogc_id

  validates_uniqueness_of :name
  validates_uniqueness_of :ogc_id

  before_validation :set_company_id

  def find_company_data
    CompaniesHouse.search_by_name(name)
  end

    def set_company_id
      unless company_id
        companies = Company.retrieve_by_name(self.name)
        if companies.size == 1
          self.company_id = companies.first.id
        end
      end
    end
end
