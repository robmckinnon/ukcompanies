class CompaniesController < ApplicationController



  
  # fuzzy match
  def search
     @query  =  params[:q]
     #@nice_name = name.gsub(/_|-/,' ').titleize
     @companies = Company.find_all_by_company_name(@query)
     redirect_to companies_url(@companies.first) if @companies.size == 1
  end
      
  # exact match
  def show
    #name  =  params[:path].first if params[:path].instance_of?(Array) 
    #@nice_name = name.gsub(/_|-/,' ').titleize
    @company = Company.find(:first)    
  end


end
