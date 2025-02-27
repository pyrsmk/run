RSpec.describe Markdown::CodeTag do
  let(:string){ "`#{SecureRandom.hex}`" }

  subject{ described_class.new(string) }

  describe "#tokens" do
    it "returns the right tokens" do
      expect(subject.send(:tokens)).to contain_exactly("`")
    end
  end

  describe "#convert" do
    it "converts the passed string" do
      expect(subject.send(:convert, string)).to eq "\033[36m#{string}\033[0m"
    end
  end
end
