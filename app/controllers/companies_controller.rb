class CompaniesController < ApplicationController

  before_filter :ensure_current_url, :only => [:show, :companies_house]

  def search
    @query  =  params[:q]
    @companies = Company.find_all_by_company_name(@query)

    if @companies.empty?
      begin
        @companies = [Company.find_this(@query)]
      rescue
        @companies = []
      end
    end
    redirect_to :controller=>"companies", :action=>"show", :id => @companies.last.friendly_id if @companies.size == 1
  end

  def show
  end
  
  def companies_house
    p params
    if @company.companies_house_url.blank?
      redirect_to company_path(@company)
    else
      redirect_to @company.companies_house_url
    end
  end

  private

    def ensure_current_url
      begin
        unless params[:id].include? '+'
          @company = Company.find_this(params[:id])
          redirect_to :controller=>"companies", :action=>"show", :id => @companies.last.friendly_id, :status => :moved_permanently if @company.has_better_id?
        end
      rescue
        render_not_found
      end
    end
end
