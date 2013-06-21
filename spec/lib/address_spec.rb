require_relative '../../spec/lib/spec_helper'

describe Justiz::Address do
  context "simple address" do
    subject { Justiz::Address.new('Schlossbezirk 3, 76131 Karlsruhe') }

    it { expect(subject.city).to eq 'Karlsruhe' }
    it { expect(subject.street).to eq 'Schlossbezirk 3' }
    it { expect(subject.plz).to eq '76131' }
  end
end
