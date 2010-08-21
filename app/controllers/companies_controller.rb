
class CompaniesController < ApplicationController

  def show_by_number
    @company = Company.retrieve_by_number(params[:number])
    if @company
      respond_to do |format|
        format.html { redirect_to show_by_number_and_name_url(params[:country_code], params[:number], @company.friendly_id), :status=>303 } # 303 = 'See Other'
        format.rdf { redirect_to show_by_number_and_name_url(params[:country_code], params[:number], @company.friendly_id), :status=>303 } # 303 = 'See Other'
        format.js  { render :json => @company.to_json }
        format.xml { render :xml => @company.to_more_xml(request.host) }
      end
    else
      render_not_found
    end
  end

  def show_by_number_and_name
    @company = Company.find_from_company_number(params[:number])
    raise ActiveRecord::RecordNotFound unless (@company and @company.friendly_id == params[:name])
    respond_to do |format|
      format.html { render "show" }
      format.rdf { render "show" }
      format.js  { render :json => @company.to_json }
      format.xml { render :xml => @company.to_more_xml(request.host) }
    end
  end

  def search
    if params[:commit]
      params.delete(:commit)
      redirect_to params
    elsif params[:q]
      @query = params[:q]
      exception = nil
      begin
        @companies = Company.retrieve_by_name(@query)
      rescue Timeout::Error => e
        exception = e
        @companies = []
      rescue CompaniesHouse::Exception => e
        exception = e
        @companies = []
      end

      if @companies.empty?
        begin
          @companies = [Company.retrieve_by_number(@query)].compact
        rescue CompaniesHouse::Exception => e
          exception = e
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
          xml = @companies.collect{|x| x.to_more_xml(request.host) }.join("\n")
        end
        xml = xml.gsub('<?xml version="1.0" encoding="UTF-8"?>','')
        error = exception ? %Q| error="#{exception.to_s}"| : ''
        render :xml => %Q|<?xml version="1.0" encoding="UTF-8"?>\n<companies result-size="#{@companies.size}"#{error}>#{xml}</companies>|
      elsif format == 'js'
        render :json => @companies.to_json
      elsif @companies.size == 1
        company = @companies.first
        redirect_to show_by_number_and_name_url(company.country_code, company.company_number, company.friendly_id), :status=>303 # 303 = 'See Other'
      else
        # show search view
      end
    else
      @companies = []
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
    @company = Company.find_from_company_number(params[:number])
    if @company.companies_house_url.blank?
      redirect_to show_by_number_and_name_url(params[:country_code], params[:number], @company.friendly_id), :status=>303 # 303 = 'See Other'
    else
      redirect_to @company.companies_house_url
    end
  end

  def preview
    country_code = params[:country_code]
    number = params[:number]
    company = Company.find_from_company_number(number, country_code)
    render :text => company.to_flyout
  end

  def flyout
    puts params.inspect
    if callback = params[:callback]
      hash = {}
      subject_id = params[:id]
      parts = subject_id.split('/')
      country_code = parts[1]
      company_number = parts[2]
      company = Company.find_from_company_number(company_number, country_code)

      hash = { :id => subject_id, :html => company.to_flyout }
      render :json => hash.to_json, :callback => callback
    else
      render :text => ''
    end
  end

  def suggest
    if callback = params[:callback]
      puts params.inspect
      start_timer
      duration = stop_timer
      term = params[:prefix]
      start = params[:start] ? params[:start].to_i : 0

      limit = start + 10
      results = Company.single_query(term, limit)
      remaining = results.size - start
      results = if remaining > 0
        results.last(remaining)
      else
        []
      end
      result = results.collect do |company, score, is_match|
        company.to_gridworks_suggest_hash(score)
      end
      hash = {
          :code => '/api/status/ok',
          :cost => "#{duration} msec",
          :prefix => term,
          :result => result,
          :start => limit,
          :status => '200 OK',
          :transaction_id => "cache;cache04.p01.sjc1:8101;2010-08-21T15:40:59Z;0048"
      }
      render :json => hash.to_json, :callback => callback
    else
      logger.info "'ERE"
    end
  end

  def reconcile
    start_timer
    if callback = params[:callback]
      render :json => service_metadata, :callback => callback
    elsif queries = params[:queries]
      hash = JSON.parse queries
      results = Company.multiple_query hash
      results.keys.each do |key|
        companies = results[key]
        results[key] = { :result => gridworks_hash(companies) }
      end
      duration = stop_timer
      results[:duration] = duration
      json = results.to_json
      logger.info json
      render :json => json
    elsif query = params[:query]
      hash = JSON.parse query
      companies = Company.single_query hash
      duration = stop_timer
      result = ActiveSupport::OrderedHash.new
      result[:result] = gridworks_hash(companies)
      result[:duration] = duration
      json = result.to_json
      logger.info json
      render :json => json
    else
      render :json => service_metadata
    end
  end

  private

    def gridworks_hash companies
      companies.map do |x|
        hash = x[0].to_gridworks_hash
        hash[:score] = x[1]
        hash[:match] = x[2]
        hash
      end
    end

    def service_metadata
      %Q|{
  "name":"CompaniesOpen.org UK Reconciliation Service",
  "identifierSpace":"http://rdf.freebase.com/ns/type.object.id",
  "schemaSpace":"http://rdf.freebase.com/ns/type.object.id",
  "view":{
    "url":"http://localhost:3000{{id}}"
  },
  "preview":{
    "url":"http://localhost:3000{{id}}/preview",
    "width":430,
    "height":300
  },
  "suggest" : {
    "entity" : {
      "service_url" : "http://localhost:3000/uk",
      "service_path" : "/suggest",
      "flyout_service_path" : "/flyout"
    }
  },
  "defaultTypes":[{
      "id":"/organization/organization",
      "name":"Organization"
    }
  ]

}|
    end

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

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      (Time.now - @start_time) * 1000
    end
end
