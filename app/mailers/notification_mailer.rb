class NotificationMailer < ActionMailer::Base
  default :from => ENV['APPLICATION_FEEDBACK_FROM_EMAIL']
	layout 'mailer'

  def can_migrate(message)
    @message = message
    mail(:to => ENV['APPLICATION_FEEDBACK_TO_EMAIL'], :subject => message.subject)
  end

  def new_user(message)
    @message = message
    mail(:to => message.to, :subject => message.subject)
  end

end
