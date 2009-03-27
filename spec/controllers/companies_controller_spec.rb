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

  describe 'asked for company by number' do
    it 'should find company' do
      Company.should_receive(:find_by_company_number).and_return @company
      get :show_by_number, :country_code => 'uk', :number => '02158715'
    end
  end
end
