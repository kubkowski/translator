ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara'
require 'capybara/rails'
require 'selenium-webdriver'

Selenium::WebDriver.for :firefox
Capybara.default_driver = :selenium

# Define a bare test case to use with Capybara
class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
    include Capybara::DSL
    include Rails.application.routes.url_helpers
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  self.use_transactional_fixtures = false
end
