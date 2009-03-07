class OgcSupplier < ActiveRecord::Base

  belongs_to :company

  validates_presence_of :name
  validates_presence_of :ogc_id

  validates_uniqueness_of :name
  validates_uniqueness_of :ogc_id
end
