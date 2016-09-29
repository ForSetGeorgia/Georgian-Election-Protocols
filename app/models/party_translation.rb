class PartyTranslation < ActiveRecord::Base
  #######################################
  ## RELATIONSHIPS
  belongs_to :party

  #######################################
  ## ATTRIBUTES
  attr_accessible :party_id, :name, :locale

  #######################################
  ## VALIDATIONS
  validates :name, :locale, :presence => true

end
