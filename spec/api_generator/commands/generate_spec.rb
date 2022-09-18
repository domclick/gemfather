require 'spec_helper'

# rubocop:disable RSpec/AnyInstance
RSpec.describe ApiGenerator::Commands::Generate do
  context 'when arguments are correct' do
    let(:argv) { ['namespace:action:post', '--paginate'] }

    it 'executes the commands' do
      allow_any_instance_of(ApiGenerator::Services::CreateScaffold).to receive(:call)
      expect_any_instance_of(ApiGenerator::Services::CreateScaffold).to receive(:call)

      expect { described_class.new(argv).call }.not_to raise_error(SystemExit)
    end
  end

  context 'when arguments are correct no paginate' do
    let(:argv) { ['namespace:action:post'] }

    it 'executes the commands' do
      allow_any_instance_of(ApiGenerator::Services::CreateScaffold).to receive(:call)
      expect_any_instance_of(ApiGenerator::Services::CreateScaffold).to receive(:call)

      expect { described_class.new(argv).call }.not_to raise_error(SystemExit)
    end
  end

  # rubocop:disable Style/RedundantBegin, Lint/SuppressedException
  context 'when arguments are incorrect' do
    let(:argv) { ['ready:steady:go'] }

    it 'exits' do
      begin
        expect { described_class.new(argv).call }.to output(/Usage:/).to_stdout
        expect { described_class.new(argv).call }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

      # Ловим exit, поскольку без rescue RSpec останавливает прогон тестов
      rescue SystemExit
      end
    end
  end
  # rubocop:enable Style/RedundantBegin, Lint/SuppressedException
end
# rubocop:enable RSpec/AnyInstance
