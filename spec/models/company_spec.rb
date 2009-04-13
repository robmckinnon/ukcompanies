require File.dirname(__FILE__) + '/../spec_helper'

describe Company do

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
end
