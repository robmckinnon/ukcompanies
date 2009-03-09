class CompaniesController < ApplicationController

  before_filter :ensure_current_url, :only => [:show, :companies_house]

  def search
    if params[:commit]
      params.delete(:commit)
      redirect_to params
    else
      @query = params[:q]
      @companies = Company.find_all_by_company_name(@query)

      if @companies.empty?
        begin
          @companies = [Company.find_this(@query)]
        rescue
          @companies = []
        end
      end

      if params[:format] == 'xml'
        render :xml => @companies.first.to_more_xml if @companies.size == 1
      elsif @companies.size == 1
        redirect_to :controller=>"companies", :action=>"show", :id => @companies.last.friendly_id, :format => params[:format]
      else
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml { render :xml => @company.to_more_xml }
    end
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
          redirect_to :controller=>"companies", :action=>"show", :id => @company.friendly_id, :status => :moved_permanently if @company.has_better_id?
        end
      rescue
        render_not_found
      end
    end
end
