module Checksure
  def self.search_by_name(name)
    url = Google.search(name, 'checksure.biz')
    return nil if url.nil?
    companies = companies_from_listing(url)
    
    search_name = name.downcase
    companies.detect { |c| c[:name].downcase == search_name }
  end
  
  protected
  
  def self.companies_from_listing(url)
    page = Hpricot(open(url))
    results = (page/"//td[@class='company']")
    results.map do |company_elem|
      name = (company_elem/"//a").first.inner_html.strip
      address = company_elem.parent.next_sibling.children[1].inner_html.strip
      number = company_elem.parent.next_sibling.children[3].children.first.to_s.strip
      { :company_number => number, :name => name, :address => address }
    end
  end
end
