class CompaniesController < ApplicationController

  def search
    term = params[:q]
    
  end

  # fuzzy match
  def index
    @query = params[:q]
    @companies = Company.find_all_by_company_name(@query)
    
  end

  # exact match
  def show
    name  =  params[:path].first if params[:path].instance_of?(Array) 
    @nice_name = name.gsub(/_|-/,' ').titleize
    @company = Company.find_by_name(name)  
  end


end
