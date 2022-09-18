require 'spec_helper'

RSpec.describe ApiGenerator::Middleware::RaiseErrorDsl do
  let(:klass) { Class.new.instance_exec(described_class) { |dsl| extend dsl } }

  context 'when add new_error' do
    before do
      klass.class_eval { on_status 499, error: :new_error }
    end

    it 'creates new middleware class in extended class namespace' do
      expect(klass.const_get(:ErrorCodeMiddleware)).to satisfy do |middleware_class|
        middleware_class < ApiGenerator::Middleware::ErrorCodeMiddleware
      end
      expect(klass.const_get(:ErrorCodeMiddleware).error_mapping).to include(499)
    end
  end
end
