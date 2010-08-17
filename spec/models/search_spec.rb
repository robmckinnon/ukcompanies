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

  describe 'when asked to normalize term' do
    it 'should squeeze spaces' do
      Search.normalize_term('Acme  Ltd').should == 'Acme Ltd'
    end
    it 'should add space to terms less than 4 chars' do
      Search.normalize_term('ABC').should == 'ABC '
      Search.normalize_term('AB ').should == 'AB '
    end
  end

  describe 'when asked to find from term' do
    before do
      @term = 'ABC '
    end
    it 'should return search if term matches exactly' do
      expected_search = mock(Search, :term => @term)
      Search.should_receive(:find_by_term).with(@term, :include => :companies).and_return expected_search
      Search.find_from_term(@term).should == expected_search
    end
    it 'should return nil if term does not match exactly' do
      Search.should_receive(:find_by_term).with(@term, :include => :companies).and_return mock(Search, :term => @term.downcase)
      Search.find_from_term(@term).should be_nil
    end
  end
end
