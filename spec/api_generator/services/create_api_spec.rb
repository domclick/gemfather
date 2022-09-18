require 'spec_helper'

RSpec.describe ApiGenerator::Services::CreateApi do
  describe 'create api' do
    let(:prepare) do
      proc do |dir|
        FileUtils.touch("#{dir}/domclick_app.gemspec")
        FileUtils.mkdir_p("#{dir}/lib/app")
        FileUtils.touch("#{dir}/lib/app/client.rb")
        File.write("#{dir}/lib/app/client.rb", '# INCLUDES', mode: 'w')
      end
    end

    let(:generate) { ->(dir) { described_class.new(dir, data).call } }

    let(:app_name) { 'domclick_app' }
    let(:app_short_name) { 'app' }
    let(:namespace) { 'deals' }
    let(:action) { 'create' }
    let(:http_method) { 'post' }
    let(:paginate) { false }

    let(:data) do
      ApiGenerator::Models::Data.new(
        action: action,
        paginate: paginate,
        app_name: app_name,
        app_short_name: app_short_name,
        namespace: namespace,
        http_method: http_method,
      )
    end

    let(:read_file) do
      proc do |path, dir|
        prepare.call(dir)
        generate.call(dir)
        File.read(File.expand_path(path, dir))
      end
    end

    context 'when created api and specs' do
      it 'creates all files' do
        Dir.mktmpdir do |dir|
          prepare.call(dir)
          generate.call(dir)

          expect(File.exist?("#{dir}/lib/app/client.rb")).to be(true)
          expect(File.exist?("#{dir}/lib/app/api/deals.rb")).to be(true)
          expect(File.exist?("#{dir}/spec/api/deals_spec.rb")).to be(true)
        end
      end
    end

    context 'when created client' do
      it 'has specific text' do
        Dir.mktmpdir do |dir|
          client = read_file.call('./lib/app/client.rb', dir)

          expect(client).to(include('include App::Api::Deals'))
        end
      end
    end

    context 'when created api spec' do
      it 'has specific text' do
        Dir.mktmpdir do |dir|
          spec = read_file.call('./spec/api/deals_spec.rb', dir)

          expect(spec).to(include('App::Api::Deals'))
          expect(spec).to(include('App.client'))
          expect(spec).to(include('expect { client.create(params) }'))
        end
      end

      context 'when handler is paginated' do
        let(:paginate) { true }

        it 'has specific text' do
          Dir.mktmpdir do |dir|
            api = read_file.call('./lib/app/api/deals.rb', dir)

            expect(api).to(include('ApiGenerator::Pagination::Dsl'))
          end
        end
      end
    end

    context 'when created api namespace' do
      it 'has specific text' do
        Dir.mktmpdir do |dir|
          api = read_file.call('./lib/app/api/deals.rb', dir)

          expect(api).to(include('connection.post(CREATE_PATH, request)'))
          expect(api).to(
            include("module App\n  module Api\n    module Deals\n"),
          )
          expect(api).to(include('def create(request_or_hash)'))
        end
      end
    end
  end
end
