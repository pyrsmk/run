RSpec.describe Markdown::AbstractTag do
  class DummyTag
    include Markdown::AbstractTag
    def tokens
      ['#']
    end
    def convert(string)
      "foo#{string}bar"
    end
  end

  let(:string){ SecureRandom.hex }
  let(:value){ "abc" + '#' + string + '#' + "def" }
  subject{ DummyTag.new(value) }

  describe "#initialize" do
    let(:value) do
      [
        string,
        DummyTag.new(SecureRandom.hex),
        Markdown::BoldTag.new(SecureRandom.hex),
        Markdown::CodeTag.new(SecureRandom.hex),
        Markdown::ItalicTag.new(SecureRandom.hex),
      ].sample
    end

    context "when passing a valid value" do
      it "does not raise" do
        expect{subject}.to_not raise_error
      end
    end

    context "when passing an invalid value" do
      let(:value) do
        [
          [true, false].sample,
          SecureRandom.hex.to_sym,
          Array.new,
          Hash.new,
        ].sample
      end
      it "raises" do
        expect{subject}.to raise_error(ArgumentError, Regexp.new(value.class.name))
      end
    end
  end

  describe "#tokens" do
    class IncompleteDummyTag
      include Markdown::AbstractTag
    end

    subject{ IncompleteDummyTag.new(string) }

    it "raises" do
      expect{subject.send(:tokens)}.to raise_error(NotImplementedError)
    end
  end

  describe "#convert" do
    class IncompleteDummyTag
      include Markdown::AbstractTag
    end

    subject{ IncompleteDummyTag.new(value) }

    it "raises" do
      expect{subject.send(:convert, SecureRandom.hex)}.to raise_error(NotImplementedError)
    end
  end

  describe "#to_ansi" do
    it "returns the expected value" do
      expect(subject.to_ansi).to eq "abcfoo#{string}bardef"
    end
  end
end
