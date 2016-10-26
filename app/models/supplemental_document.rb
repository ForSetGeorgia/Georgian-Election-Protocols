class SupplementalDocument < ActiveRecord::Base
  #######################################
  ## RELATIONSHIPS
  belongs_to :district_precinct

  #######################################
  ## ATTRIBUTES
  attr_accessible :district_precinct_id, :file_path, :is_amendment, :is_explanatory_note

  #######################################
  ## VALIDATIONS
  validates :district_precinct_id, :file_path, :presence => true


end
