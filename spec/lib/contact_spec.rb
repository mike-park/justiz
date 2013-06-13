require 'rspec'
require 'justiz'

describe Justiz::Contact do
  it "should find all" do
    contacts = subject.gerichte('ALL', 'BRD')
    ap contacts
    expect(contacts.count).to eq(12)
  end
end
