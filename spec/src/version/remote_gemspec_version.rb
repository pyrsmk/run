RSpec.describe Version::RemoteGemspecVersion do
  subject{ described_class.new("https://raw.githubusercontent.com/pyrsmk/run/master/run_tasks.gemspec") }

  describe "#extract" do
    it "extracts the version number" do
      expect(subject.extract).to match /(\d+).(\d+).(\d+)/
    end

    context "when the file contents have no version" do
      subject{ described_class.new("https://raw.githubusercontent.com/pyrsmk/run/master/Gemfile") }

      it "raises an UnreachableError" do
        expect{subject.extract}.to raise_error(Version::UnreachableError)
      end
    end

    context "when there's a network error" do
      let(:error) do
        [SocketError].sample.new
      end

      before do
        allow(URI).to receive(:parse).and_raise(error)
      end

      it "raises an UnreachableError" do
        expect{subject.extract}.to raise_error(Version::UnreachableError)
      end
    end
  end
end
