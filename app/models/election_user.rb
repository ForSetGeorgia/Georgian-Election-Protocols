class ElectionUser < ActiveRecord::Base

  #######################################
  ## RELATIONSHIPS
  belongs_to :user
  belongs_to :election

  #######################################
  ## VALIDATIONS
  validates :election_id, :user_id, :presence => true
  validates_uniqueness_of :user_id, scope: :election_id

  #######################################
  ## ATTRIBUTES
  attr_accessible :election_id, :user_id
end
