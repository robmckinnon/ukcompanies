class CompaniesController < ApplicationController

  before_filter :ensure_current_url, :only => [:show]

  def show_by_number
    company = Company.find_by_company_number(params[:number])
    if company
      if params[:format] && params[:format] == 'xml'
        render :xml => company.to_more_xml
      else
        redirect_to show_by_number_and_name_url(params[:number], company.friendly_id), :status=>303 # 303 = 'See Other'
      end
    else
      render_not_found
    end
  end

  def show_by_number_and_name
    company = Company.find_by_company_number(params[:number])
    if company && (company.friendly_id == params[:name])
      @company = company
      render "show"
    else
      render_not_found
    end
  end

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

      format = params[:format] || params[:f]
      if format == 'xml'
        if @companies.empty?
          xml = ''
        elsif @companies.size == 1
          xml = @companies.first.to_more_xml
        else
          xml = @companies.collect(&:to_more_xml).join("\n")
        end
        xml = xml.gsub('<?xml version="1.0" encoding="UTF-8"?>','')
        render :xml => %Q|<?xml version="1.0" encoding="UTF-8"?>\n<companies result-size="#{@companies.size}">#{xml}</companies>|
      elsif @companies.size == 1
        redirect_to show_by_number_and_name_url(params[:number], company.friendly_id), :status=>303 # 303 = 'See Other'
      else
        # show search view
      end
    end
  end

  def show
    params[:format] = params[:f] if params[:f]
    respond_to do |format|
      format.html
      format.rdf
      format.xml { render :xml => @company.to_more_xml }
    end
  end

  def companies_house
    p params
    @company = Company.find_by_company_number(params[:number])
    if @company.companies_house_url.blank?
      redirect_to show_by_number_and_name_url(params[:number], @company.friendly_id), :status=>303 # 303 = 'See Other'
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
