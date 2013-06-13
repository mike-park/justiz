require 'rspec'
require 'justiz'
require 'awesome_print'

describe Justiz::Scraper::Courts do
  context "Bundesgerichte" do
    it "should find all Bundesgerichte" do
      contacts = subject.scrape('ALL', 'BRD')
      ap contacts
      expect(contacts.count).to eq(12)
    end
  end


  context "NRW" do
    it "should find all NRW" do
      contacts = subject.scrape('ALL', 'NRW')
      #ap contacts
      expect(contacts.count).to eq(12)
    end
  end
end

