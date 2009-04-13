class SearchResult < ActiveRecord::Base

  belongs_to :search
  belongs_to :company

end
