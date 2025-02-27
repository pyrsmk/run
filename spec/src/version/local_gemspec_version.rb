RSpec.describe Version::LocalGemspecVersion do
  subject{ described_class.new(Gemspec::Metadata.new("run_tasks")) }

  describe "#extract" do
    it "extracts the version number" do
      expect(subject.extract).to match /(\d+).(\d+).(\d+)/
    end
  end
end
