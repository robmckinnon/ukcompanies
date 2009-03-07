require 'rubygems'
require 'net/http'
require 'connection'
require 'cgi'
require 'rexml/document'
require 'hpricot'
require 'ostruct'
Server = 'wck2.companieshouse.gov.uk'
SessionRe= 'wck2.companieshouse.gov.uk\/(.*)\/wcframe\?name=accessCompanyInfo'

module CompaniesHouse
  class CompaniesHouseConnection
    attr_reader :sessionId
    def initialize
      @connection=Connection.new(Server)
      @redirect=@connection.get('/')['location']
      @sessionId=@redirect.match(SessionRe)[1]
    end
    def searchByName(name)
      path="/#{sessionId}/companysearch"
      result=@connection.post(path,'cname'=>name,'cosearch'=>'1','cotype0'=>'1','stype'=>'E')
      redirect=result['location']
      path="/#{sessionId}/#{redirect}"
      @connection.get(path)
    end
    def queryACompany(link)
      path="/#{sessionId}/#{link}"
      result=@connection.get(path)
      redirect=result['location']
      path="/#{sessionId}/#{redirect}"
      result=@connection.get(path)
     end
  end
  class CompanySearch
    def initialize(name,connection)
      @connection=connection
      answer=@connection.searchByName(name)
      @doc=Hpricot(answer.body)
      @companies={}
      @doc.search("//tr[@class='resC']").each do |row|
        result=Company.new(row,@connection)
        @companies[result.name]=result  
      end
    end
    
    attr_reader :companies
  end
  
  class Company
    attr_reader :id,:name,:status,:action,:link,:nameReturn,:business
    def initialize(row,connection)
      result=OpenStruct.new
      @connection=connection
      @id=row.search("td[1]/a").inner_html
      @name=row.search("td[3]").inner_html
      @status=row.search("td[2]").inner_html
      @action=row.search("td[4]").inner_html
      @link=row.search("td[1]").inner_html.match("href=\"(.*)\" class")[1]
    end

    def parseLink
      @data={}
      html=Hpricot(@connection.queryACompany(@link).body)
      headers=html.search('td[@class="yellowCreamTable]/strong').each do |val|
        data_maybe=val.next_node
        data_maybe=data_maybe.next_node while (data_maybe.to_s==":" or data_maybe.to_s=="<br />")
        @data[val.inner_html]=data_maybe.to_s
      end
      @business=@data["Nature of Business (SIC(03))"]
    end
  end
  
end
