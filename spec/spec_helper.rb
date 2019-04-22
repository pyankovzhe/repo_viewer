# frozen_string_literal: true

ENV['APP_ENV'] = 'test'
require 'bundler/setup'
Bundler.require(:test)
require_relative '../app'

SPEC_DIR = Pathname(__FILE__).dirname
Dir[SPEC_DIR.join('support/**/*.rb')].each { |f| require f }
Dir[SPEC_DIR.join('../lib/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include LinkHelpers
  config.include TyphoeusHelpers
  config.include JsonFixturesHelpers

  config.before :each do
    Typhoeus::Expectation.clear
  end
end
