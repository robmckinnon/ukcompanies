class SearchResult < ActiveRecord::Base

  has_one :search
  has_one :company

end
