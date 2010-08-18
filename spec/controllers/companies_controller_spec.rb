
require File.dirname(__FILE__) + '/../spec_helper'

describe CompaniesController do

  before do
    @company = mock(Company, :friendly_id=>'bgl-rieber-limited')
  end

  it 'should route number url correctly' do
    route_for(:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'NL18709799').should == "/uk/NL18709799"
    route_for(:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'02158715').should == "/uk/02158715"

    route_for(:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'NL18709799', :format=>'xml').should == "/uk/NL18709799.xml"
    route_for(:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'02158715', :format=>'xml').should == "/uk/02158715.xml"

    params_from(:get, "/uk/NL18709799").should == {:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'NL18709799'}
    params_from(:get, "/uk/02158715").should == {:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'02158715'}

    params_from(:get, "/uk/NL18709799.xml").should == {:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'NL18709799', :format=>'xml'}
    params_from(:get, "/uk/02158715.xml").should == {:controller => "companies", :action => "show_by_number", :country_code=>'uk', :number=>'02158715', :format=>'xml'}
  end

  it 'should route number and name url correctly' do
    route_for(:controller => "companies", :action => "show_by_number_and_name", :country_code=>'uk', :number=>'NL18709799', :name=>'bdo-stoy-hayward').should == "/uk/NL18709799/bdo-stoy-hayward"
    route_for(:controller => "companies", :action => "show_by_number_and_name", :country_code=>'uk', :number=>'02158715', :name=>'bgl-rieber-limited').should == "/uk/02158715/bgl-rieber-limited"

    params_from(:get, "/uk/NL18709799/bdo-stoy-hayward").should == {:controller => "companies", :action => "show_by_number_and_name", :country_code=>'uk', :number=>'NL18709799', :name=>'bdo-stoy-hayward'}
    params_from(:get, "/uk/02158715/bgl-rieber-limited").should == {:controller => "companies", :action => "show_by_number_and_name", :country_code=>'uk', :number=>'02158715', :name=>'bgl-rieber-limited'}
  end

  it 'should route reconcile url correctly' do
    route_for(:controller => 'companies', :country_code => 'uk', :action => 'reconcile').should == '/uk/reconcile'
    route_for(:controller => 'companies', :country_code => 'uk', :action => 'reconcile', :callback=>'json123').should == '/uk/reconcile?callback=json123'

    params_from(:get, '/uk/reconcile').should == { :controller => 'companies', :country_code => 'uk', :action => 'reconcile' }
    params_from(:get, '/uk/reconcile?callback=json123').should == { :controller => 'companies', :country_code => 'uk', :action => 'reconcile', :callback => 'json123' }

    params_from(:post, '/uk/reconcile').should == { :controller => 'companies', :country_code => 'uk', :action => 'reconcile' }
  end

  describe 'asked for company by number' do
    it 'should find company' do
      @company.should_receive(:missing_attributes?).and_return false
      Company.should_receive(:find_by_company_number).and_return @company
      get :show_by_number, :country_code => 'uk', :number => '02158715'
    end
  end

  describe 'when doing reconciliation' do
    before do
      @company0 = Company.new :name => 'British Retail Consortium Associated', :company_number => '1', :country_code => 'uk'
      @company1 = Company.new :name => 'British Retail Consortium Ltd', :company_number => '2', :country_code => 'uk'
      @company2 = Company.new :name => 'British Retail Consortium Plc', :company_number => '3', :country_code => 'uk'
      @companies = [ [@company0,33.3,false], [@company1,33.3,false], [@company2,33.3,false] ]
    end

    describe 'and asked single query' do
      before do
        @json = %Q|{"query":"BritishAmerican Business"}|
        @hash = JSON.parse @json
        @query_json = %Q|{"query"=>"#{@json}"}|
        @results = @companies
      end

      it 'should query company model' do
        @controller.should_receive(:start_timer)
        @controller.should_receive(:stop_timer).and_return 1001
        Company.should_receive(:single_query).with(@hash).and_return @results
        post :reconcile, :country_code => 'uk', :query => @json
        response.body.should == '{"result":[{"id":"/uk/1","name":"British Retail Consortium Associated","type":[{"name":"Organization","id":"/organization/organization"}],"score":33.3,"match":false},{"id":"/uk/2","name":"British Retail Consortium Ltd","type":[{"name":"Organization","id":"/organization/organization"}],"score":33.3,"match":false},{"id":"/uk/3","name":"British Retail Consortium Plc","type":[{"name":"Organization","id":"/organization/organization"}],"score":33.3,"match":false}],"duration":1001}'
      end
    end

    describe 'and asked multiple query' do
      before do
        @json = %Q|{"q0":{"query":"BritishAmerican Business","limit":3},"q1":{"query":"British Retail Consortium","limit":3},"q2":{"query":"IoD","limit":3},"q3":{"query":"Brindex","limit":3},"q4":{"query":"Association of Electricity Producers","limit":3},"q5":{"query":"Permira","limit":3},"q6":{"query":"JCA Group","limit":3},"q7":{"query":"GKN","limit":3},"q8":{"query":"KPMG","limit":3},"q9":{"query":"Eli Lilley","limit":3}}|
        @hash = JSON.parse @json
        @query_json = %Q|{"queries"=>"#{@json}"}|

        @results = {
          'q0' => [],
          'q1' => @companies,
          'q2' => []
        }
      end

      it 'should query company model' do
        @controller.should_receive(:start_timer)
        @controller.should_receive(:stop_timer).and_return 1001
        Company.should_receive(:multiple_query).with(@hash).and_return @results
        post :reconcile, :country_code => 'uk', :queries => @json
        response.body.should == '{"q1":{"result":[{"id":"/uk/1","name":"British Retail Consortium Associated","type":[{"name":"Organization","id":"/organization/organization"}],"score":33.3,"match":false},{"id":"/uk/2","name":"British Retail Consortium Ltd","type":[{"name":"Organization","id":"/organization/organization"}],"score":33.3,"match":false},{"id":"/uk/3","name":"British Retail Consortium Plc","type":[{"name":"Organization","id":"/organization/organization"}],"score":33.3,"match":false}]},"q2":{"result":[]},"duration":1001,"q0":{"result":[]}}'
      end
    end
  end

  describe 'when asked for reconciliation service metadata' do
    before do
      @metadata = %Q|{
  "name":"CompaniesOpen.org UK Reconciliation Service",
  "identifierSpace":"http://rdf.freebase.com/ns/type.object.id",
  "schemaSpace":"http://rdf.freebase.com/ns/type.object.id",
  "view":{
    "url":"http://localhost:3000{{id}}"
  },
  "preview":{
    "url":"http://localhost:3000{{id}}",
    "width":430,
    "height":300
  },
  "defaultTypes":[{
      "id":"/organization/organization",
      "name":"Organization"
    }
  ]
}|
    end

    it 'should return service metadata' do
      get :reconcile, :country_code => 'uk'
      response.body.should == @metadata
      response.code.should == '200'
      response.content_type.should == 'application/json'
    end

    describe 'and callback is set' do
      it 'should return service metadata as a function' do
        callback_name = 'json123'
        get :reconcile, :country_code => 'uk', :callback => callback_name
        response.body.should == "#{callback_name}(#{@metadata})"
        response.code.should == '200'
        response.content_type.should == 'application/json' # investigate later whether this should be 'application/javascript'
      end
    end
  end

end
