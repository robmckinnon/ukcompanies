class Search < ActiveRecord::Base

  has_many :search_results, :dependent => :delete_all

  has_many :companies, :through => :search_results, :source => :company

  validates_uniqueness_of :term

end
