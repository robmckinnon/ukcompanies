class LobbyistClient < ActiveRecord::Base

  belongs_to :company

  validates_presence_of :name
  validates_uniqueness_of :name

  before_validation :set_company_id

  private
    def set_company_id
      unless company_id
        companies = Company.find_all_by_company_name(self.name)
        if companies.size == 1
          self.company_id = companies.first.id
        end
      end
    end
end
