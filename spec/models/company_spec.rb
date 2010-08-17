require File.dirname(__FILE__) + '/../spec_helper'

describe Company do

  describe 'to gridworks hash' do
    name = 'Canonical Limited'
    company = Company.create :name => name, :company_number => '123', :country_code => 'uk'
    hash = company.to_gridworks_hash
    hash[:name].should == name
    hash[:id].should == 'http://localhost/uk/123'
    hash[:type].first[:id].should == '/organization/organization'
    hash[:type].first[:name].should == 'Organization'

    Company.delete_all
  end

  describe 'creating friendly id' do
    it 'should allow multiple companies to have same friendly id' do
      company = Company.create :name => 'Canonical Limited', :company_number => '123'
      company.friendly_id.should == 'canonical-limited'

      company = Company.create! :name => 'Canonical Limited', :company_number => '124'
      company.friendly_id.should == 'canonical-limited'

      Company.delete_all
      # Company.should_receive(:find_by_company_number).and_return @company
      # get :show_by_number, :number => '02158715'
    end
  end

  describe 'handling reconciliation' do
    before do
      @q0 = 'BritishAmerican Business'
      @q1 = 'British Retail Consortium'
      @q2 = 'IoD'
      @company0 = mock(Company, :name => 'British Retail Consortium Associated')
      @company1 = mock(Company, :name => 'British Retail Consortium Ltd')
      @company2 = mock(Company, :name => 'British Retail Consortium Plc')
      @company3 = mock(Company, :name => 'IoD')
      @companies = [@company0, @company1, @company2]
      @results = [ [@company0,69.44,false], [@company1,86.2,false], [@company2,86.2,false] ]
    end

    describe 'handling single query' do
      before do
        @search = mock(Search, :companies => @companies)
      end

      it 'should look for matching results' do
        Search.should_receive(:find_by_term).with(@q1, :include => :companies).and_return @search
        @search.should_receive(:reconciliation_results).with(@q1, nil).and_return @results

        results = Company.single_query(@q1)

        results.should == @results
      end
    end

    describe 'handling multiple query' do
      before do
        @json = %Q|{"q0":{"query":"#{@q0}","limit":2},"q1":{"query":"#{@q1}","limit":2},"q2":{"query":"#{@q2}","limit":2}}|
        @search = mock(Search, :companies => @companies)
        @search2 = mock(Search, :companies => [@company3])
        @hash = JSON.parse @json

        @results1 = [ [@company0,69.44,false], [@company1,86.2,false] ]
        @results2 = [ [@company3,90.0,true] ]
      end

      it 'should look for existing search results' do
        Search.should_receive(:find_by_term).with(@q0, :include => :companies).and_return nil
        Search.should_receive(:find_by_term).with(@q1, :include => :companies).and_return @search
        Search.should_receive(:find_by_term).with(@q2, :include => :companies).and_return @search2

        @search.should_receive(:reconciliation_results).with(@q1, 2).and_return @results1
        @search2.should_receive(:reconciliation_results).with(@q2, 2).and_return @results2
        results = Company.multiple_query(@hash)
        results.should have_key('q0')
        results.should have_key('q1')
        results.should have_key('q2')
        results['q0'].should == []
        results['q1'].should == @results1
        results['q2'].should == @results2
      end
    end
  end
end
