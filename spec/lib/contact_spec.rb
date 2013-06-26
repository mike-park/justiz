require 'rspec'
require 'justiz'

describe Justiz::Contact do
  let(:court) { {court: 'Staatsanwaltschaft Düsseldorf',
                 location: 'Fritz-Roeber-Straße 2, 40213 Düsseldorf',
                 post: 'P.O.Box 123, 40999 Düsseldorf - Post',
                 phone: '0211 6025 0',
                 fax: '0211 6025 2929',
                 justiz_id: 'R1100S',
                 url: 'http://www.sta-duesseldorf.nrw.de',
                 email: 'poststelle@sta-duesseldorf.nrw.de'} }

  let(:contact) { Justiz::Contact.new(court) }

  it "should assign elements" do
    %w(court location post phone fax justiz_id url email).each do |field|
      field = field.to_sym
      expect(contact.send(field)).to eq(court[field])
    end
  end

  it "should parse addresses" do
    expect(contact.location_address.plz).to eq('40213')
    expect(contact.post_address.plz).to eq('40999')
  end

  it "should have an id" do
    id = "#{court[:court]}#{court[:email]}"
    expect(contact.id).to eq(id)
  end

  it "should have a digest" do
    digest = "76ef09d0c7d0078015df7a948cf0352c00f6451dab354389b21895a50d89a4a8"
    expect(contact.digest).to eq(digest)
  end
end
