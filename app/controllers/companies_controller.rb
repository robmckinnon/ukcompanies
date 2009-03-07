class CompaniesController < ApplicationController

  def search
    term = params[:q]
    companies = Company.find_by_company_name(term)
  end

  def index
    @query = params[:q]
  end

  def show
    name  =  params[:path].first if params[:path].instance_of?(Array) 
    @nice_name = name.gsub(/_|-/,' ').titleize
  end


end
