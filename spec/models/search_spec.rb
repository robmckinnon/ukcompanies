require File.dirname(__FILE__) + '/../spec_helper'

describe Search do
  assert_model_has_many :search_results

  describe 'when asked for limited number of companies' do
    before do
      @search = Search.new
      @company0 = mock(Company, :name => 'British Retail Consortium Associated')
      @company1 = mock(Company, :name => 'British Retail Consortium Ltd')
      @company2 = mock(Company, :name => 'British Retail Consortium Plc')
      @companies = [@company0, @company1, @company2]
    end

    it 'should limit companies returned' do
      @search.stub!(:companies).and_return @companies
      results = @search.reconciliation_results('British Retail Consortium',2)
      results.size.should == 2
    end

    it 'should calculate scores and match boolean' do
      @search.stub!(:companies).and_return @companies
      results = @search.reconciliation_results('British Retail Consortium',2)
      results.should == [ [@company0,69.44,false], [@company1,86.2,false] ]
    end
  end
end
