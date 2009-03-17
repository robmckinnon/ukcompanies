require File.dirname(__FILE__) + '/../spec_helper'

describe Company do

  describe 'creating friendly id' do
    it 'should allow multiple companies to have same friendly id' do
      company = Company.create :name => 'Canonical Limited'
      company.friendly_id.should == 'canonical-limited'

      company = Company.create :name => 'Canonical Limited'
      company.friendly_id.should == 'canonical-limited'
      # Company.should_receive(:find_by_company_number).and_return @company
      # get :show_by_number, :number => '02158715'
    end
  end
end
