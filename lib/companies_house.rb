require 'net/http'
require 'cgi'
require 'rexml/document'
require 'hpricot'
require 'ostruct'

module CompaniesHouse
  Server = 'wck2.companieshouse.gov.uk'
  SessionRe= 'wck2.companieshouse.gov.uk\/(.*)\/wcframe\?name=accessCompanyInfo'
  
  def self.search_by_name(name)
    connection=CompaniesHouseConnection.new
    answer=CompanySearch.new(name,connection)
    if answer.companies.size == 1
      company = answer.companies.values.first
      company.parse_link
      company.data
    else
      p answer.companies
      puts answer.companies.size
      nil
    end
  end
  
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
  
  
  class Connection

      def initialize(server, options = {})
        unless options.is_a?(Hash)
          raise "Fourth argument must be a hash of options!"
        end
        @server = server
        @format = options[:format] || (defined?(JSON) ? :json : :xml)     
        @enable_caching = options[:enable_caching]
        if @enable_caching
          $cache ||= {}
        end
        # Make connection to server
        @http = Net::HTTP.new(@server)
        @http.read_timeout = 5
        @http.set_debug_output($stdout) if options[:enable_debug]
      end

      attr_reader :format

      def timeout
        @http.read_timeout
      end

      def timeout=(t)
        @http.read_timeout = t
      end

      def version
        @version
      end

      def valid?
        @username && @password && @server
      end


      def get(path, data = {})
        # Allow format override
        format = data.delete(:format) || @format
        # Create URL parameters
        params = []
        data.each_pair do |key, value|
          params << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
        end
        if params.size > 0
          path += "?#{params.join('&')}"
        end
        # Send request
        return $cache[path] if @enable_caching and $cache[path]
        response = do_request(Net::HTTP::Get.new(path), format)
        $cache[path] = response if @enable_caching
        return response
      end

      def post(path, data = {})
        # Allow format override
        format = data.delete(:format) || @format
        # Clear cache
        clear_cache
        # Create POST request
        post = Net::HTTP::Post.new(path)
        body = []
          data.each_pair do |key, value|
          body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
        end
        post.body = body.join '&'
        # Send request
        do_request(post, format)
      end

      def put(path, data = {})
        # Allow format override
        format = data.delete(:format) || @format
        # Clear cache
        clear_cache
        # Create PUT request
        put = Net::HTTP::Put.new(path)
        body = []
          data.each_pair do |key, value|
          body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
        end
        put.body = body.join '&'
        # Send request
        do_request(put, format)
      end

      def delete(path)
        clear_cache
        # Create DELETE request
        delete = Net::HTTP::Delete.new(path)
        # Send request
        do_request(delete)
      end

      protected

      def content_type(format = @format)
        case format
        when :xml
          return 'application/xml'
        when :json
          return 'application/json'
        when :atom
          return 'application/atom+xml'
        end
      end

      def redirect?(response)
        response.code == '301' || response.code == '302'
      end

      def response_ok?(response)
        case response.code
          when '200'
            return true
          when '302'
          return true
          when '403'
            raise "You do not have permission to perform the requested operation. Response: #{response.body}"
          when '401'
            return false
          else
            raise "An error occurred: HTTP response code #{response.code}. Response: #{response.body}"
        end
      end

      def do_request(request, format = @format)
        # Open HTTP connection
        @http.start
        # Do request
        begin
          response = send_request(request, format)
        end while !response_ok?(response)
        # Return body of response
        return response
      rescue SocketError
        raise "Connection failed. Check server name or network connection."
      ensure
        # Close HTTP connection
        @http.finish if @http.started?
      end

      def send_request(request, format = @format)
        request['Accept'] = content_type(format)
        response = @http.request(request)
        # Handle 404s
        if response.code == '404'
          raise "URL doesn't exist on server."
        end
        # Done
        response
      end

      def clear_cache
        if @enable_caching
          $cache = {}
        end
      end

    end
  
end
