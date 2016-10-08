module UpdateVolunteers
  require 'csv'
  require 'open-uri'

  @@url = "https://docs.google.com/spreadsheets/d/1dAI4nbKB6C4GO9yPC79BeHVmo0J4YSuVQOrawoLVIhk/pub?gid=1995298987&single=true&output=csv"
  @@paid_url = "#{Rails.root}/lib/PaidVolunteers.csv"

  @@names = ["Alliance", "Armed", "Christian", "Christian-Democratic", "Communist", "Council", "Country", "Democratic", "Democrats", "Dream", "European", "Fair", "For", "Forum", "Free", "Freedom", "Future", "Georgia", "Georgian", "Government", "Greens", "Group", "Hall", "Homeland", "Idea", "In", "Industrialists", "Industry", "Initiative", "Ivanishvili", "Kostava", "Labour", "Leftist", "Lord", "Mamulishvili", "Merab", "Movement", "Name", "National", "New", "Nikoloz", "Non-Parliamentary", "Opposition", "Our", "Ours", "Ourselves", "Party", "Patriots", "Peace", "People", "People's", "Politics", "Progressive", "Public", "Radical", "Reformers", "Republican", "Right", "Rights", "Save", "Self-governance", "Socialist", "Society", "Solidarity", "Sportsman's", "Stalin", "State", "Topadze", "Tortladze", "Traditionalists", "Union", "United", "Unity", "Veterans", "Way", "We", "Whole", "Will", "Wing", "Women's", "Workers"]

  def self.get_existing_emails
    User.all.map { |u| u.email }
  end

  def self.get_vol_users(url, emails)
    csv_users = CSV.read(open(url), headers: true)
    csv_users.select { |u|  !emails.include? u[2] }
  end

  def self.get_paid_users(url, emails)
    csv_users = CSV.read(url, headers: true)
    csv_users.select { |u|  !emails.include? u[0] }
  end

  def self.fun_pwd(names)
    rand1 = names.shuffle[0]
    rand2 = names.shuffle[0]
    rand3 = names.shuffle[0]
    rand4 = (0..9).to_a.shuffle[1..4].join
    pwd = "#{rand1.titleize}#{rand2.titleize}#{rand3.titleize}#{rand4}"
  end

  def self.vol_update(url = @@url, names = @@names)
    old_users = get_existing_emails
    new_users = get_vol_users(url, old_users)
    pwd = fun_pwd(names)
    elections = Election.can_enter
    new_users.each do |u|
      nu = User.create(:email => u[2], :password => pwd)
      nu.elections << elections
    end
  end

  def send_email(users)
    users.each do |u|
      
    end
  end

  def self.paid_update(url = @@paid_url, names = @@names)
    old_users = get_existing_emails
    new_users = get_paid_users(url, old_users)
    pwd = fun_pwd(names)
    elections = Election.can_enter
    new_users.each do |u|
      nu = User.create(:email => u[0], :password => pwd)
      nu.elections << elections
    end
  end
end
