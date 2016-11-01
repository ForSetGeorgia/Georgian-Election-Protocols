class SupplementalDocument < ActiveRecord::Base
  #######################################
  ## RELATIONSHIPS
  belongs_to :district_precinct

  #######################################
  ## ATTRIBUTES
  attr_accessible :district_precinct_id, :file_path, :is_amendment, :is_explanatory_note, :is_annullment, :categorized_by_user_id

  #######################################
  ## VALIDATIONS
  validates :district_precinct_id, :file_path, :presence => true

  #######################################
  ## CALLBACKS
  after_save :update_district_precinct_flag

  def update_district_precinct_flag
    changed = false
    if self.is_amendment_changed? && self.is_amendment?
      self.district_precinct.has_amendment = true
      self.district_precinct.save
      changed = true
    elsif self.is_explanatory_note_changed? && self.is_explanatory_note?
      self.district_precinct.has_explanatory_note = true
      self.district_precinct.save
      changed = true
    elsif self.is_annullment_changed? && self.is_annullment?
      self.district_precinct.is_annulled = true
      self.district_precinct.save
      changed = true
    end

    # if there was a change, also update the analysis raw table
    if changed
      self.district_precinct.update_analysis_supplemental_document_data
    end

    return true
  end

  #######################################
  ## SCOPES
  def self.not_categorized
    where(is_amendment: false, is_explanatory_note: false, is_annullment: false)
  end

  def self.is_categorized
    where('is_amendment = 1 or is_explanatory_note = 1 or is_annullment = 1')
  end

  def self.next_to_categorize
    id = not_categorized.pluck(:id).sample
    if id.present?
      return find(id)
    else
      return nil
    end
  end

  def self.by_user(user_id)
    where(categorized_by_user_id: user_id)
  end

  def self.not_by_user(user_id)
    where(['categorized_by_user_id != ?', user_id])
  end

  def self.user_stats(user_id)
    stats = Hash.new
    stats[:total_completed] = is_categorized.count
    stats[:completed_by_user] = Hash.new
    stats[:completed_by_user][:raw] = by_user(user_id).is_categorized.count
    stats[:completed_by_user][:number] = format_number(stats[:completed_by_user][:raw])
    stats[:completed_by_user][:percent] = stats[:total_completed] > 0 ? format_percent(100*stats[:completed_by_user][:raw]/stats[:total_completed].to_f) : I18n.t('app.common.na')
    stats[:completed_by_others] = Hash.new
    stats[:completed_by_others][:raw] = not_by_user(user_id).is_categorized.count
    stats[:completed_by_others][:number] = format_number(stats[:completed_by_others][:raw])
    stats[:completed_by_others][:percent] = stats[:total_completed] > 0 ? format_percent(100*stats[:completed_by_others][:raw]/stats[:total_completed].to_f) : I18n.t('app.common.na')
    stats[:remaining] = Hash.new
    stats[:remaining][:raw] = not_categorized.count
    stats[:remaining][:number] = format_number(stats[:remaining][:raw])
    return stats
  end

  def self.document_stats
    stats = Hash.new
    stats[:total] = count
    stats[:amendment] = Hash.new
    stats[:amendment][:raw] = where(is_amendment: true).count
    stats[:amendment][:number] = format_number(stats[:amendment][:raw])
    stats[:amendment][:percent] = stats[:total] > 0 ? format_percent(100*stats[:amendment][:raw]/stats[:total].to_f) : I18n.t('app.common.na')
    stats[:annulled] = Hash.new
    stats[:annulled][:raw] = where(is_annullment: true).count
    stats[:annulled][:number] = format_number(stats[:annulled][:raw])
    stats[:annulled][:percent] = stats[:total] > 0 ? format_percent(100*stats[:annulled][:raw]/stats[:total].to_f) : I18n.t('app.common.na')
    stats[:explanatory_note] = Hash.new
    stats[:explanatory_note][:raw] = where(is_explanatory_note: true).count
    stats[:explanatory_note][:number] = format_number(stats[:explanatory_note][:raw])
    stats[:explanatory_note][:percent] = stats[:total] > 0 ? format_percent(100*stats[:explanatory_note][:raw]/stats[:total].to_f) : I18n.t('app.common.na')
    stats[:unknown] = Hash.new
    stats[:unknown][:raw] = not_categorized.count
    stats[:unknown][:number] = format_number(stats[:unknown][:raw])
    stats[:unknown][:percent] = stats[:total] > 0 ? format_percent(100*stats[:unknown][:raw]/stats[:total].to_f) : I18n.t('app.common.na')
    return stats
  end

  protected


  def self.format_number(number)
    ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(number))
  end

  def self.format_percent(number)
    ActionController::Base.helpers.number_to_percentage(ActionController::Base.helpers.number_with_precision(number))
  end

end
