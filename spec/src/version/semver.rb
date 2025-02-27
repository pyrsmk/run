RSpec.describe Version::Semver do
  let(:major){ rand(0..9) }
  let(:minor){ rand(0..9) }
  let(:patch){ rand(0..9) }
  let(:value){ "#{major}.#{minor}.#{patch}" }

  subject{ described_class.new(value) }

  describe "#initialize" do
    context "when passing a valid value" do
      it "does not raise" do
        expect{subject}.to_not raise_error
      end
    end

    context "when passing an invalid value" do
      let(:value) do
        [
          rand(0..9).to_s,
          "#{rand(0..9)}.#{rand(0..9)}",
          "#{rand(0..9)}.#{rand(0..9)}.#{rand(0..9)}.#{rand(0..9)}",
        ].sample
      end

      it "raises" do
        expect{subject}.to raise_error(ArgumentError)
      end
    end
  end

  describe "#major" do
    it "returns the right value" do
      expect(subject.major).to eq major
    end
  end

  describe "#minor" do
    it "returns the right value" do
      expect(subject.minor).to eq minor
    end
  end

  describe "#patch" do
    it "returns the right value" do
      expect(subject.patch).to eq patch
    end
  end

  describe "#<" do
    let(:value){ "1.2.3" }

    context "when the passed version is superior" do
      let(:version) do
        [
          OpenStruct.new(major: rand(2..9), minor: rand(0..9), patch: rand(0..9)),
          OpenStruct.new(major: 1, minor: rand(3..9), patch: rand(0..9)),
          OpenStruct.new(major: 1, minor: 2, patch: rand(4..9)),
        ].sample
      end

      it "returns true" do
        expect(subject < version).to be true
      end
    end

    context "when the passed version is inferior or equal" do
      let(:version) do
        [
          OpenStruct.new(major: rand(0..1), minor: rand(0..2), patch: rand(0..2)),
          OpenStruct.new(major: rand(0..1), minor: rand(0..1), patch: rand(0..9)),
          OpenStruct.new(major: 0, minor: rand(0..9), patch: rand(0..9)),
          OpenStruct.new(major: 1, minor: 2, patch: 3),
        ].sample
      end

      it "returns false" do
        expect(subject < version).to be false
      end
    end
  end

  describe "#>" do
    let(:value){ "1.2.3" }

    context "when the passed version is inferior or equal" do
      let(:version) do
        [
          OpenStruct.new(major: rand(0..1), minor: rand(0..2), patch: rand(0..2)),
          OpenStruct.new(major: rand(0..1), minor: rand(0..1), patch: rand(0..9)),
          OpenStruct.new(major: 0, minor: rand(0..9), patch: rand(0..9)),
        ].sample
      end

      it "returns true" do
        expect(subject > version).to be true
      end
    end

    context "when the passed version is superior or equal" do
      let(:version) do
        [
          OpenStruct.new(major: rand(2..9), minor: rand(0..9), patch: rand(0..9)),
          OpenStruct.new(major: 1, minor: rand(3..9), patch: rand(0..9)),
          OpenStruct.new(major: 1, minor: 2, patch: rand(4..9)),
          OpenStruct.new(major: 1, minor: 2, patch: 3),
        ].sample
      end

      it "returns false" do
        expect(subject > version).to be false
      end
    end
  end

  describe "#==" do
    let(:value){ "1.2.3" }

    context "when the passed version is the same" do
      let(:version){ OpenStruct.new(major: 1, minor: 2, patch: 3) }

      it "returns true" do
        expect(subject == version).to be true
      end
    end

    context "when the passed version is different" do
      let(:version) do
        OpenStruct.new(
          major: [0, rand(2..9)].sample,
          minor: [rand(0..1), rand(3..9)].sample,
          patch: [rand(0..2), rand(4..9)].sample,
        )
      end

      it "returns false" do
        expect(subject == version).to be false
      end
    end
  end
end
