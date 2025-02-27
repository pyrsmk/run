RSpec.describe Markdown::BoldTag do
  let(:string) do
    [
      "**#{SecureRandom.hex}**",
      "__#{SecureRandom.hex}__",
    ].sample
  end

  subject{ described_class.new(string) }

  describe "#tokens" do
    it "returns the right tokens" do
      expect(subject.send(:tokens)).to contain_exactly("**", "__")
    end
  end

  describe "#convert" do
    it "converts the passed string" do
      expect(subject.send(:convert, string)).to eq "\033[1m#{string}\033[0m"
    end
  end
end
