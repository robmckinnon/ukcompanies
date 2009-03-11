require 'rubygems'
require 'httparty'

class GoogleImageSearch
  include HTTParty
  base_uri 'ajax.googleapis.com'
  default_params :output => 'json'
  format :json

  # Example: 
  #  GoogleImageSearch.find_named_logo('VODAFONE UK LIMITED')
  #
  # TODO: add some additional error checking. E.g. timeouts, seeing image still exists
  def self.find_named_logo(name, options = {})
    size   = options[:size] ||= 'medium'
    result = get('/ajax/services/search/images', :query => {:v=> '1.0', :q => "\"#{name}\" logo", :imgsz => options[:size], :safe => 'active'})
    result['responseData']['results'].first unless result['responseData']['results'].empty?
  end

  # short version of above
  def self.find_named_logo_url(name, options = {})
    if result = find_named_logo(name, options)
      result['url']
    end
  end
  
  # An example of how we could extend this for grabbing the homepage url.. would need to namespace this lib better also
  # def self.find_homepage_url(name, options = {})
  #     result = get('/ajax/services/search/web', :query => {:v=> '1.0', :q => "\"#{name}\" homepage",  :safe => 'active'})
  #     result['responseData']['results'].first unless result['responseData']['results'].empty?
  #   end
      
end
