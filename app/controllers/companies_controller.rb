class CompaniesController < ApplicationController

  def show_by_number
    @company = Company.retrieve_by_number(params[:number])
    if @company
      respond_to do |format|
        format.html { redirect_to show_by_number_and_name_url(params[:country_code], params[:number], @company.friendly_id), :status=>303 } # 303 = 'See Other'
        format.rdf { redirect_to show_by_number_and_name_url(params[:country_code], params[:number], @company.friendly_id), :status=>303 } # 303 = 'See Other'
        format.xml { render :xml => @company.to_more_xml(request.host) }
      end
    else
      render_not_found
    end
  end

  def show_by_number_and_name
    @company = Company.find_by_company_number(params[:number])
    raise ActiveRecord::RecordNotFound unless (@company and @company.friendly_id == params[:name])
    respond_to do |format|
      format.html { render "show" }
      format.rdf { render "show" }
      format.xml { render :xml => @company.to_more_xml }
    end
  end

  def search
    if params[:commit]
      params.delete(:commit)
      redirect_to params
    else
      @query = params[:q]
      @companies = Company.retrieve_by_name(@query)

      if @companies.empty?
        begin
          @companies = [Company.retrieve_by_number(@query)].compact
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
        company = @companies.first
        redirect_to show_by_number_and_name_url(company.country_code, company.company_number, company.friendly_id), :status=>303 # 303 = 'See Other'
      else
        # show search view
      end
    end
  end

  def show
    @companies = Company.find_all_by_slug(params[:id])
    format = params[:f] ? params[:f] : params[:format]

    if @companies.empty?
      redirect_to :controller=>'home', :action=>'index'
    elsif @companies.size == 1
      company = @companies.first
      redirect_to show_by_number_and_name_url(company.country_code, company.company_number, company.friendly_id), :status=>303, :format=>format # 303 = 'See Other'
    else
      @query = @companies.first.name
      render :action=>'search', :format=>format
    end

    # respond_to do |format|
      # format.html
      # format.rdf
      # format.xml { render :xml => @company.to_more_xml }
    # end
  end

  def companies_house
    p params
    @company = Company.find_by_company_number(params[:number])
    if @company.companies_house_url.blank?
      redirect_to show_by_number_and_name_url(params[:country_code], params[:number], @company.friendly_id), :status=>303 # 303 = 'See Other'
    else
      redirect_to @company.companies_house_url
    end
  end

  private

    def ensure_current_url
      begin
        raise 'hi'
        identifier = params[:id]
        unless identifier.include? '+'
          if identifier[Company::NUMBER_PATTERN]
            @company = retrieve_by_number(identifier)
          else
            @company = find(identifier)
            # redirect_to show_by_number_and_name_url(@company.company_number, @company.friendly_id)
            redirect_to :controller=>"companies", :action=>"show", :id => @company.friendly_id, :status => :moved_permanently if @company.has_better_id?
          end
        end
      rescue
        render_not_found
      end
    end
end
