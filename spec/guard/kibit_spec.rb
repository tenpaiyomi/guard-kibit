# frozen_string_literal: true

RSpec.describe Guard::Kibit, :silence_output do
  subject(:guard) { Guard::Kibit.new(options) }
  let(:options) { {} }

  describe '#options' do
    subject { super().options }

    context 'by default' do
      let(:options) { {} }

      describe '[:all_on_start]' do
        subject { super()[:all_on_start] }
        it { should be_truthy }
      end

      describe '[:notification]' do
        subject { super()[:notification] }
        it { should == :failed }
      end
    end
  end

  describe '#start' do
    context 'when :all_on_start option is enabled' do
      let(:options) { { all_on_start: true } }

      it 'runs all' do
        expect(guard).to receive(:run_all)
        guard.start
      end
    end

    context 'when :all_on_start option is disabled' do
      let(:options) { { all_on_start: false } }

      it 'does nothing' do
        expect(guard).not_to receive(:run_all)
        guard.start
      end
    end
  end

  shared_examples 'processes after running', :processes_after_running do
    context 'when passed' do
      it 'throws nothing' do
        allow_any_instance_of(Guard::Kibit::Runner).to receive(:run).and_return(true)
        expect { subject }.not_to throw_symbol
      end
    end

    context 'when failed' do
      it 'throws symbol :task_has_failed' do
        allow_any_instance_of(Guard::Kibit::Runner).to receive(:run).and_return(false)
        expect { subject }.to throw_symbol(:task_has_failed)
      end
    end

    context 'when an exception is raised' do
      it 'prevents itself from firing' do
        allow_any_instance_of(Guard::Kibit::Runner).to receive(:run).and_raise(RuntimeError)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#run_all', :processes_after_running do
    subject { super().run_all }

    before do
      allow_any_instance_of(Guard::Kibit::Runner).to receive(:run).and_return(true)
    end

    it 'inspects all files with kibit' do
      expect_any_instance_of(Guard::Kibit::Runner).to receive(:run).with([])
      guard.run_all
    end
  end

  %i[run_on_additions run_on_modifications].each do |method|
    describe "##{method}", :processes_after_running do
      subject { super().send(method, changed_paths) }
      let(:changed_paths) do
        [
          'lib/guard/kibit.rb',
          'spec/spec_helper.rb'
        ]
      end

      before do
        allow_any_instance_of(Guard::Kibit::Runner).to receive(:run).and_return(true)
      end

      it 'inspects changed files with kibit' do
        expect_any_instance_of(Guard::Kibit::Runner).to receive(:run)
        subject
      end

      it 'passes cleaned paths to kibit' do
        expect_any_instance_of(Guard::Kibit::Runner).to receive(:run) do |_instance, paths|
          expect(paths).to eq([
            File.expand_path('lib/guard/kibit.rb'),
            File.expand_path('spec/spec_helper.rb')
          ])
        end
        subject
      end

      context 'when cleaned paths are empty' do
        before do
          allow(guard).to receive(:clean_paths).and_return([])
        end

        it 'does nothing' do
          expect_any_instance_of(Guard::Kibit::Runner).not_to receive(:run)
          subject
        end
      end

      it 'inspects just changed paths' do
        expect_any_instance_of(Guard::Kibit::Runner).to receive(:run) do |_instance, paths|
          expect(paths).to eq([
            File.expand_path('lib/guard/kibit.rb'),
            File.expand_path('spec/spec_helper.rb')
          ])
        end
        subject
      end
    end
  end

  describe '#clean_paths' do
    def clean_paths(path)
      guard.send(:clean_paths, path)
    end

    it 'converts to absolute paths' do
      paths = [
        'lib/guard/kibit.rb',
        'spec/spec_helper.rb'
      ]
      expect(clean_paths(paths)).to eq([
        File.expand_path('lib/guard/kibit.rb'),
        File.expand_path('spec/spec_helper.rb')
      ])
    end

    it 'removes duplicated paths' do
      paths = [
        'lib/guard/kibit.rb',
        'spec/spec_helper.rb',
        'lib/guard/../guard/kibit.rb'
      ]
      expect(clean_paths(paths)).to eq([
        File.expand_path('lib/guard/kibit.rb'),
        File.expand_path('spec/spec_helper.rb')
      ])
    end

    it 'removes non-existent paths' do
      paths = [
        'lib/guard/kibit.rb',
        'path/to/non_existent_file.rb',
        'spec/spec_helper.rb'
      ]
      expect(clean_paths(paths)).to eq([
        File.expand_path('lib/guard/kibit.rb'),
        File.expand_path('spec/spec_helper.rb')
      ])
    end

    it 'removes paths which are included in another path' do
      paths = [
        'lib/guard/kibit.rb',
        'spec/spec_helper.rb',
        'spec'
      ]
      expect(clean_paths(paths)).to eq([
        File.expand_path('lib/guard/kibit.rb'),
        File.expand_path('spec')
      ])
    end
  end

  describe '#smart_path' do
    def smart_path(path)
      guard.send(:smart_path, path)
    end

    context 'when the passed path is under the current working directory' do
      let(:path) { File.expand_path('spec/spec_helper.rb') }

      it 'returns relative path' do
        expect(smart_path(path)).to eq('spec/spec_helper.rb')
      end
    end

    context 'when the passed path is outside of the current working directory' do
      let(:path) do
        tempfile = Tempfile.new('')
        tempfile.close
        File.expand_path(tempfile.path)
      end

      it 'returns absolute path' do
        expect(smart_path(path)).to eq(path)
      end
    end
  end
end
