# frozen_string_literal: true

# Configures how email is sent from this application
class ApplicationMailer < ActionMailer::Base
  default from: Settings.email.from
  # layout "mailer"
end
