require File.dirname(__FILE__) + '/../spec_helper'

describe CompaniesController do

  before do
    @company = mock(Company, :friendly_id=>'bgl-rieber-limited')
  end

  it 'should route number url correctly' do
    route_for(:controller => "companies", :action => "show_by_number", :number=>'NL18709799').should == "/NL18709799"
    route_for(:controller => "companies", :action => "show_by_number", :number=>'02158715').should == "/02158715"

    params_from(:get, "/NL18709799").should == {:controller => "companies", :action => "show_by_number", :number=>'NL18709799'}
    params_from(:get, "/02158715").should == {:controller => "companies", :action => "show_by_number", :number=>'02158715'}
  end

  it 'should route number and name url correctly' do
    route_for(:controller => "companies", :action => "show_by_number_and_name", :number=>'NL18709799', :name=>'bdo-stoy-hayward').should == "/NL18709799/bdo-stoy-hayward"
    route_for(:controller => "companies", :action => "show_by_number_and_name", :number=>'02158715', :name=>'bgl-rieber-limited').should == "/02158715/bgl-rieber-limited"

    params_from(:get, "/NL18709799/bdo-stoy-hayward").should == {:controller => "companies", :action => "show_by_number_and_name", :number=>'NL18709799', :name=>'bdo-stoy-hayward'}
    params_from(:get, "/02158715/bgl-rieber-limited").should == {:controller => "companies", :action => "show_by_number_and_name", :number=>'02158715', :name=>'bgl-rieber-limited'}
  end

  describe 'asked for company by number' do
    it 'should find company' do
      Company.should_receive(:find_by_company_number).and_return @company
      get :show_by_number, :number => '02158715'
    end
  end
end