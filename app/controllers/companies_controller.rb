class CompaniesController < ApplicationController

  def search
    term = params[:q]
    companies = Company.find_by_company_name(term)
  end

  def index
  end

end
