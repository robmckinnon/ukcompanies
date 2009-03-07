
module Google
  def self.search(query, site=nil)
    encoded_query = URI.encode query
    url = "http://www.google.com/search?&q=%22#{encoded_query}%22"
    url += "%20site%3A#{site}" if site
  
    doc = Hpricot open(url)
    results = (doc / 'h3.r/a')
    if results.size > 0
      result = results.first['href']
    else
      results = (Hpricot(open(url)) / 'h2.r/a')
      if results.size > 0
        result = results.first['href']
      end
    end
  end
end
