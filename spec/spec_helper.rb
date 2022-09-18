# frozen_string_literal: true

require_relative '../lib/api_generator'

require 'webmock/rspec'
require 'dry/configurable/test_interface'
require 'tmpdir'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class ApiGenerator::Client::Connection
  enable_test_interface
end
