class Search < ActiveRecord::Base

  has_many :search_results, :dependent => :delete_all

end
