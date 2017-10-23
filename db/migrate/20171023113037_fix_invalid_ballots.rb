class FixInvalidBallots < ActiveRecord::Migration
  def up
    # when local major was turned on, many ballots started getting marked as invalid
    # due to the major district id being inproperly saved by other elections
    # this will re-check all invalid crowd datum records for 10/23 and
    # see if they are actually valid now that the major dist id is fixed
    user_ids = User.where('last_sign_in_at >= "2017-10-23"').pluck(:id)

    user_ids.each do |user_id|

      cd_ids = CrowdDatum.where(user_id: user_id, is_valid:false).pluck(:id)

      if cd_ids.present?
        cd_ids.each do |cd_id|
          cd = CrowdDatum.find_by_id(cd_id)
          cd.match_and_validate if cd.present?
        end
      end
    end

    # fixes
  end

  def down
    puts "do nothing"
  end
end
