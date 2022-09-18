require 'spec_helper'

RSpec.describe ApiGenerator::Services::CreateModel do
  describe 'create models' do
    let(:prepare) do
      proc do |dir|
        FileUtils.touch("#{dir}/domclick_api.gemspec")
        FileUtils.mkdir_p("#{dir}/lib/api")
      end
    end
    let(:generate) { ->(dir) { described_class.new(dir, data).call } }

    let(:app_name) { 'domclick_api' }
    let(:app_short_name) { 'api' }
    let(:namespace) { 'deals' }
    let(:action) { 'create' }
    let(:http_method) { 'post' }
    let(:paginate) { true }

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

    it 'creates model files' do
      Dir.mktmpdir do |dir|
        prepare.call(dir)

        generate.call(dir)

        expect(File.exist?("#{dir}/lib/api/model/deals/create/request.rb")).to be true
        expect(File.exist?("#{dir}/lib/api/model/deals/create/response.rb")).to be true
        expect(File.exist?("#{dir}/spec/model/deals/create/request_spec.rb")).to be true
        expect(File.exist?("#{dir}/spec/model/deals/create/response_spec.rb")).to be true
      end
    end

    context 'when created models' do
      it 'has specific text' do
        Dir.mktmpdir do |dir|
          request = read_file.call('./lib/api/model/deals/create/request.rb', dir)
          response = read_file.call('./lib/api/model/deals/create/response.rb', dir)

          expect(request).to(include('class Request < ApiGenerator::Models::Base'))
          expect(response).to(include('class Response < ApiGenerator::Models::Base'))
        end
      end
    end

    context 'when created model specs' do
      it 'has specific text' do
        Dir.mktmpdir do |dir|
          request_spec = read_file.call('./spec/model/deals/create/request_spec.rb', dir)
          response_spec = read_file.call('./spec/model/deals/create/response_spec.rb', dir)

          expect(request_spec).to(include('Api::Model::Deals::Create::Request'))
          expect(response_spec).to(include('Api::Model::Deals::Create::Response'))
        end
      end
    end
  end
end
