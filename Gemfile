source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.0"
# Use postgresql as the database for Active Record
gem "pg"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Use SCSS for stylesheets
gem "sass-rails", "~> 6.0"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "6.0.0.beta.6"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Security update
gem "nokogiri", ">= 1.10.8"

gem "faraday"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "pry-rails"
  gem "annotate"
  gem "brakeman"
  gem "bundler-audit", github: "rubysec/bundler-audit"
  gem "letter_opener_web", "~> 1.3", ">= 1.3.4"
  gem "standard"
  # added by us
  gem "dotenv-rails"
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'guard-rails', require: false
  gem "guard-rspec", require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", "~> 3.2", ">= 3.2.1"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
  gem "webmock"
  gem 'faker'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Jumpstart dependencies
gem "jumpstart", path: "lib/jumpstart"

gem "acts_as_tenant"
gem "administrate", github: "excid3/administrate", branch: "jumpstart" # '~> 0.10.0'
gem "administrate-field-active_storage", "~> 0.3.0"
gem "attr_encrypted", "~> 3.1"
gem "devise", ">= 4.7.1"
gem "devise-i18n", "~> 1.9"
gem "devise_masquerade", github: "excid3/devise_masquerade"
gem "hotwire-rails", "~> 0.1.2"
gem "image_processing", "~> 1.9", ">= 1.9.2"
gem "inline_svg", "~> 1.6"
gem "invisible_captcha", "~> 2.0"
gem "local_time", "~> 2.1"
gem "name_of_person", "~> 1.0"
gem "noticed", "~> 1.3"
gem "oj", "~> 3.8", ">= 3.8.1"
gem "pagy", "~> 4.1"
gem "pay", "~> 2.6.0"
gem "pg_search", "~> 2.3"
gem "receipts", "~> 1.0.0"
gem "ruby-oembed", "~> 0.14.0", require: "oembed"

# We always want the latest versions of these gems, so no version numbers
gem "omniauth", "~> 1.9", ">= 1.9.1"
gem "strong_migrations", "~> 0.7.6"
gem "whenever", require: false
gem "paper_trail"

# Jumpstart manages a few gems for us, so install them from the extra Gemfile
if File.exist?("config/jumpstart/Gemfile")
  eval_gemfile "config/jumpstart/Gemfile"
end

gem "aasm", "~> 5.1"
gem "messagebird-rest", require: "messagebird"
gem "combine_pdf", "1.0.20"

gem "active_storage_validations", "~> 0.9.2"
gem "ransack", "~> 2.4"

gem "aws-sdk-s3", require: false

gem "simple_calendar", "~> 2.4"
