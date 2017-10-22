class User < ActiveRecord::Base
  PROTOCOL_NUMBERS = (1..5).to_a

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	# :registerable, :recoverable,
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :trained

  # use role inheritence
  # - a role with a larger number can do everything that smaller numbers can do
  ROLES = {:user => 0, :categorize_supplemental_documents => 40, :moderator => 50, :admin => 99}


  validates :role, :presence => true

  #######################################
  ## RELATIONSHIPS
  has_many :election_users, :dependent => :destroy
  has_many :elections, :through => :election_users

  #######################################
  ## SCOPES
  def self.in_election(election_ids)
    joins(:election_users).where(election_users: {election_id: election_ids})
  end

  def self.with_role(role)
    where(['role >= ?', role])
  end

  # create accounts for the provided email addresses
  def self.create_user(users)
    users = users.to_a if users.class == String

    names = ["Alliance", "Armed", "Christian", "Christian-Democratic", "Communist", "Council", "Country", "Democratic", "Democrats", "Dream", "European", "Fair", "For", "Forum", "Free", "Freedom", "Future", "Georgia", "Georgian", "Government", "Greens", "Group", "Hall", "Homeland", "Idea", "In", "Industrialists", "Industry", "Initiative", "Ivanishvili", "Kostava", "Labour", "Leftist", "Lord", "Mamulishvili", "Merab", "Movement", "Name", "National", "New", "Nikoloz", "Non-Parliamentary", "Opposition", "Our", "Ours", "Ourselves", "Party", "Patriots", "Peace", "People", "People's", "Politics", "Progressive", "Public", "Radical", "Reformers", "Republican", "Right", "Rights", "Save", "Self-governance", "Socialist", "Society", "Solidarity", "Sportsman's", "Stalin", "State", "Topadze", "Tortladze", "Traditionalists", "Union", "United", "Unity", "Veterans", "Way", "We", "Whole", "Will", "Wing", "Women's", "Workers"]

    users.each do |u|
      pwd = fun_pwd(names)
      user = User.find_by_email(u)
      if user.present?
        user.password = pwd
        user.save
      else
        user = User.create(:email => u, :password => pwd)
      end

      message = Message.new
      message.to = user.email
      message.locale = I18n.locale
      message.subject = I18n.t("mailer.new_user.subject", :locale => I18n.locale)
      message.message = I18n.t("mailer.new_user.message", :locale => I18n.locale, email: user.email, password: pwd)
      NotificationMailer.new_user(message).deliver
    end

  end

  #######################################
  ## METHODS

  def completed_training?
    trained.length >= PROTOCOL_NUMBERS.length
  end

  def trained
    y = read_attribute('trained').present? ? read_attribute('trained').split(',') : []
    y.map{|x| x.to_i}
  end

  def self.no_admins
    where("role != ?", ROLES[:admin])
  end

	# if no role is supplied, default to the basic user role
	def check_for_role
		self.role = ROLES[:user] if self.role.nil?
	end

  def role?(base_role)
    if base_role && ROLES.values.index(base_role)
      return base_role <= self.role
    end
    return false
  end

  def role_name
    ROLES.keys[ROLES.values.index(self.role)].to_s
  end

  def nickname
    self.email.split('@')[0]
  end


  def fun_pwd(names)
    rand1 = names.shuffle[0]
    rand2 = names.shuffle[0]
    rand3 = names.shuffle[0]
    rand4 = (0..9).to_a.shuffle[1..4].join
    pwd = "#{rand1.titleize}#{rand2.titleize}#{rand3.titleize}#{rand4}"
  end

end
