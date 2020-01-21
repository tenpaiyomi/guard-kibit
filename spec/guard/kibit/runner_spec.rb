# frozen_string_literal: true

RSpec.describe Guard::Kibit::Runner do
  subject(:runner) { Guard::Kibit::Runner.new(options) }
  let(:options) { {} }

  describe '#run' do
    subject { super().run(paths) }
    let(:paths) { ['spec/spec_helper.rb'] }

    before do
      allow(runner).to receive(:system)
    end

    it 'executes kibit' do
      expect(runner).to receive(:system) do |*args|
        expect(args.first).to eq('lein kibit')
      end
      runner.run
    end

    context 'when Kibit exited with 0 status' do
      before do
        allow(runner).to receive(:system).and_return(true)
      end
      it { should be_truthy }
    end

    context 'when Kibit exited with non 0 status' do
      before do
        allow(runner).to receive(:system).and_return(false)
      end
      it { should be_falsey }
    end

    shared_examples 'notifies', :notifies do
      it 'notifies' do
        expect(runner).to receive(:notify)
        runner.run
      end
    end

    shared_examples 'does not notify', :does_not_notify do
      it 'does not notify' do
        expect(runner).not_to receive(:notify)
        runner.run
      end
    end

    shared_examples 'notification' do |expectations|
      context 'when passed' do
        before do
          allow(runner).to receive(:system).and_return(true)
        end

        if expectations[:passed]
          include_examples 'notifies'
        else
          include_examples 'does not notify'
        end
      end

      context 'when failed' do
        before do
          allow(runner).to receive(:system).and_return(false)
        end

        if expectations[:failed]
          include_examples 'notifies'
        else
          include_examples 'does not notify'
        end
      end
    end

    context 'when :notification option is true' do
      let(:options) { { notification: true } }
      include_examples 'notification', passed: true, failed: true
    end

    context 'when :notification option is :failed' do
      let(:options) { { notification: :failed } }
      include_examples 'notification', passed: false, failed: true
    end

    context 'when :notification option is false' do
      let(:options) { { notification: false } }
      include_examples 'notification', passed: false, failed: false
    end
  end

  describe '#build_command' do
    subject(:build_command) { runner.build_command(paths) }
    let(:paths) { %w[file1.rb file2.rb] }

    it 'adds the passed paths' do
      expect(build_command[1..-1]).to eq(%w[file1.rb file2.rb])
    end
  end

  describe '#notify' do
    it 'notifies summary' do
      expect(Guard::Notifier).to receive(:notify) do |message, _options|
        expect(message).to eq('Finished Kibit inspection')
      end
      runner.notify(true)
    end

    it 'notifies with title "Kibit results"' do
      expect(Guard::Notifier).to receive(:notify) do |_message, options|
        expect(options[:title]).to eq('Kibit results')
      end
      runner.notify(true)
    end

    context 'when passed' do
      it 'shows success image' do
        expect(Guard::Notifier).to receive(:notify) do |_message, options|
          expect(options[:image]).to eq(:success)
        end
        runner.notify(true)
      end
    end

    context 'when failed' do
      it 'shows failed image' do
        expect(Guard::Notifier).to receive(:notify) do |_message, options|
          expect(options[:image]).to eq(:failed)
        end
        runner.notify(false)
      end
    end
  end
end
