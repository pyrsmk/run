RSpec.describe Gemspec::Metadata do
  let(:lib_name){ "run_tasks" }

  subject{ described_class.new(lib_name) }

  # We only can test the development routine, and not the production one.
  describe "#read" do
    it "reads the GemSpec metadata" do
      expect(subject.read.name).to eq lib_name
    end
  end
end
