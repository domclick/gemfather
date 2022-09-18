require 'spec_helper'

RSpec.describe ApiGenerator::Services::Gemfather do
  def expect_exists?(dir, path)
    expect(File.exist?(File.expand_path(path, dir))).to be(true)
  end

  let(:app_name) { 'new_api' }
  let(:run!) { described_class.new.generate_client(app_name) }

  # rubocop:disable RSpec/NoExpectationExample
  it 'creates correct file structure' do
    Dir.mktmpdir do |dir|
      described_class.target_dir = File.expand_path(dir)

      run!

      expect_exists?(dir, './new_api')
      expect_exists?(dir, './new_api/new_api.gemspec')
      expect_exists?(dir, './new_api/Gemfile')
      expect_exists?(dir, './new_api/Makefile')
      expect_exists?(dir, './new_api/README.md')
      expect_exists?(dir, './new_api/Rakefile')
      expect_exists?(dir, './new_api/bin/console')
      expect_exists?(dir, './new_api/bin/generate')
      expect_exists?(dir, './new_api/lib/new_api.rb')
      expect_exists?(dir, './new_api/lib/new_api/client.rb')
      expect_exists?(dir, './new_api/lib/new_api/railtie.rb')
      expect_exists?(dir, './new_api/lib/new_api/version.rb')
      expect_exists?(dir, './new_api/lib/new_api/http_errors.rb')
      expect_exists?(dir, './new_api/spec/spec_helper.rb')
      expect_exists?(dir, './new_api/log/.keep')
      expect_exists?(dir, './new_api/.git')
      expect_exists?(dir, './new_api/.gitignore')
      expect_exists?(dir, './new_api/.rubocop-rspec.yml')
      expect_exists?(dir, './new_api/.rubocop-ruby.yml')
      expect_exists?(dir, './new_api/.rubocop.yml')
    end
  end
  # rubocop:enable RSpec/NoExpectationExample
end
