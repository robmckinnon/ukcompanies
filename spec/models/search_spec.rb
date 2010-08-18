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

  describe 'when asked for sorted companies' do
    before do
      @names = [
        'SHELL COMPANY LIMITED',
        'SHELL COMPANY UK LIMITED',
        'SHELL CORPORATION LIMITED',
        'SHELL GROUP LIMITED',
        'SHELL HOLDINGS COMPANY LIMITED',
        'SHELL (HOLDINGS) LIMITED',
        'SHELL LIMITED',
        'SHELL LLP',
        'SHELL LTD',
        'SHELL LTD.',
        'SHELL PLC',
        'SHELL (G.B.) LIMITED',
        'SHELL G.B. LIMITED',
        'SHELL (GB) LIMITED',
        'SHELL GB LIMITED',
        'SHELL (U.K.) LIMITED',
        'SHELL U.K. LIMITED',
        'SHELL (UK) LIMITED',
        'SHELL UK LIMITED',
        'SHELL AND BP SCOTLAND LIMITED',
        'SHELL & BP SERVICES LIMITED',
        '"SHELL BAY" SERVICES LIMITED',
        'SHELL BAY SERVICES LIMITED',
        'SHELL - CAST SYSTEMS LIMITED',
        'SHELL-CAST SYSTEMS LIMITED',
        'THE SHELL COMPANY OF NIGERIA LIMITED',
        'SHELL (PLASTERING) LIMITED',
        'THE SHELLARS LTD',
        'SHELLBAY SOLUTIONS LTD',
        'ANOTHER SHELL LIMITED'
      ] # sorted
      @companies = (@names.reverse.last(@names.size - 5) + @names.reverse.first(5)) .inject([]) do |list, name|
        list << Company.new(:name => name)
      end
      @search = Search.new
    end

    it 'should sort correctly' do
      @search.term = 'Shell'
      @search.should_receive(:companies).and_return @companies
      names = @search.sorted_companies.map(&:name)
      @names.each_with_index do |name, index|
        names[index].should == name
      end
    end
  end
end
