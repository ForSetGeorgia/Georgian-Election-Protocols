class Message
	include ActiveAttr::Model
  include ActiveModel::Validations

	attribute :name
  attribute :email
	attribute :subject
	attribute :message
	attribute :message2
	attribute :url
	attribute :url_id
	attribute :bcc
	attribute :locale, :default => I18n.locale
  
	attr_accessible :name, :email, :message, :message2, :subject, :url, :bcc, :url_id, :locale

  validates_presence_of :email
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_length_of :message, :maximum => 500

end
