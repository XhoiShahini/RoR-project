# Assign the from email address in all environments
ActionMailer::Base.default_options = {from: Jumpstart.config.default_from_email}

if Rails.env.production? || Rails.env.staging?
  ActionMailer::Base.default_url_options[:host] = ENV.fetch('MAILER_DOMAIN', Jumpstart.config.domain)
  ActionMailer::Base.default_url_options[:protocol] = "https"
  ActionMailer::Base.smtp_settings.merge!(Jumpstart::Mailer.new(Jumpstart.config).settings)
end
