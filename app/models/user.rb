class User < ActiveRecord::Base
  PROTOCOL_NUMBERS = (1..5).to_a

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	# :registerable, :recoverable,
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role

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

  # use role inheritence
  # - a role with a larger number can do everything that smaller numbers can do
  ROLES = {:user => 0, :admin => 99}
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

end
