require '../lib/companies_house'
require 'pp'
include CompaniesHouse
describe Connection do
  it 'should connect' do
    result=Connection.new(Server)
  end
  it 'should redirect to session form' do
    result =Connection.new(Server).get('/')
    result.should be_a Net::HTTPFound
    result['location'].should match /wcframe/
  end
end

describe CompaniesHouse do
  it 'should work' do
    res=CompaniesHouse.search_by_number('06603291')
    pp res.data
  end
  it 'should give a url when comp exists' do
    CompaniesHouse.url_for_number('06603291').should match /compdetails/
  end
  it 'should not give a url when no comp exists' do
    CompaniesHouse.url_for_number('wfwfw').should be_nil
  end
end

describe CompaniesHouseConnection do
  it 'should give back a session id' do
    connection=CompaniesHouseConnection.new
    connection.sessionId.should be_a String
  end
  it 'should be able to search for a company' do
    connection=CompaniesHouseConnection.new
    name='John'
    answer=connection.searchByName(name)
    answer.body.should match Regexp.new(name)
  end
  it 'should search simply by number' do
    connection=CompaniesHouseConnection.new
    answer=Company.new
    answer.parse(connection.searchByNumber('06603291')) 
    pp answer.data
  end
end

describe CompanySearch do
  it 'should parse the results of a search' do
    connection=CompaniesHouseConnection.new
    name='Badham'
   
    results=CompanySearch.new(name,connection)
    results.companies.keys.length.should eql 13
  end
end

describe Company do
  it 'should parse the result of getting a company' do
    connection=CompaniesHouseConnection.new
    name='Badham'
    answer=CompanySearch.new(name,connection)
    company=answer.companies.values[8]
    company.parseLink # not done during constructor to avoid overloading server
    company.name.should match Regexp.new(name.upcase)
    company.business.should match /7412/
  end
end


