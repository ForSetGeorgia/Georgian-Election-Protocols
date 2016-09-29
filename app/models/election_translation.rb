class ElectionTranslation < ActiveRecord::Base
  #######################################
  ## RELATIONSHIPS
  belongs_to :election

  #######################################
  ## ATTRIBUTES
  attr_accessible :election_id, :name, :locale

  #######################################
  ## VALIDATIONS
  validates :name, :locale, :presence => true

end
