require 'open-uri'
require 'hpricot'
require 'uri'

module Acts

  module Wikipedia

    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_wikipedia(options={})
        include Acts::Wikipedia::InstanceMethods
      end
    end

    module InstanceMethods
      def populate_wikipedia_url additional_search_term=nil
        if wikipedia_url.blank?
          encoded_name = URI.encode name
          url =
          "http://www.google.com/search?&q=%22#{encoded_name}%22%20site%3Aen.wikipedia.org"
          url += "%20#{additional_search_term}" if additional_search_term

          puts url
          doc = Hpricot open(url)
          results = (doc / 'h3.r/a')
          puts results
          if results.size > 0
            self.wikipedia_url = results.first['href']
          else
            url =
            "http://www.google.com/search?&q=#{encoded_name}%20site%3Aen.wikipedia.org"
            url += "%20#{additional_search_term}" if additional_search_term
            results = (Hpricot(open(url)) / 'h2.r/a')
            if results.size > 0
              self.wikipedia_url = results.first['href']
            end
          end
        end
      end
    end                                            

  end
end

ActiveRecord::Base.send(:include, Acts::Wikipedia)