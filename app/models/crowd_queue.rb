class CrowdQueue < ActiveRecord::Base

  #######################
  # flag descriptions
  #######################
  # is_finished
  # - by default is null which means that it the district/precinct has been assigned but not finished
  # - 0 = time expired or user went on to new item
  # - 1 = item was finished


  #######################
  ## VALIDATIONS
  validates :election_id, :district_id, :precinct_id, :user_id, :presence => true

  #######################################
  ## RELATIONSHIPS
  belongs_to :election


  MAX_TIME = 5


  # clean the queue from old items that were never finished
  # and remove all unfinished items for this user
  def self.clean_queue(user_id=nil)
    # mark old records as not finished
    CrowdQueue.where("is_finished is null and created_at < ?", MAX_TIME.minutes.ago).update_all(:is_finished => false)

    # if this user has any pending records, marked as not finished
    CrowdQueue.where("is_finished is null and user_id = ?", user_id).update_all(:is_finished => false) if user_id.present?
  end


  # mark a queue item as finished
  def self.finished(election_id, district_id, precinct_id, user_id)
    logger.debug "))) crowd queue finished"
    if election_id.present? && user_id.present? && district_id.present? && precinct_id.present?
      logger.debug "))) - found match, marking as finished"
      CrowdQueue.where(["election_id = ? and user_id = ? and district_id = ? and precinct_id = ? and is_finished is null", election_id, user_id, district_id, precinct_id]).update_all(:is_finished => true)
    end
  end
end
