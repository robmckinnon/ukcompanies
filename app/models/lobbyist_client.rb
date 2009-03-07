class LobbyistClient < ActiveRecord::Base

  belongs_to :company

  validates_presence_of :name

  validates_uniqueness_of :name

end
