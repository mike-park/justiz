# encoding: utf-8

require_relative '../../lib/spec_helper'

describe Justiz::Scraper::Courts do
  it "should have court types" do
    types = {
        "AG" => "Amtsgerichte",
        "LG" => "Landgerichte",
        "OLG" => "Oberlandesgerichte",
        "STA" => "Staatsanwaltschaften",
        "MG" => "Mahngerichte",
        "FAM" => "Familiengerichte",
        "INS" => "Insolvenzgerichte",
        "HREG" => "Handels-/Genossenschaftsregister",
        "VREG" => "Vereinsregistergerichte",
        "PREG" => "Partnerschaftsregistergerichte",
        "ZVG" => "Zwangsversteigerungsgerichte",
        "ZVK" => "Zentrale Vollstreckungsgerichte",
        "SG" => "Sozialgerichte",
        "VG" => "Verwaltungsgerichte",
        "ARB" => "Arbeitsgerichte",
        "FG" => "Finanzgerichte",
        "VFG" => "Verfassungsgerichte",
        "JM" => "Justizministerium",
        "JVA" => "Vollzugseinrichtungen",
        "AND" => "Sonstige Justizbehörden"
    }
    VCR.use_cassette 'courts/homepage' do
      expect(subject.court_types).to eq(types)
    end
  end

  it "should have states" do
    types = {
        "BRD" => "Bundesgerichte/-behörden",
        "BW" => "Baden-Württemberg",
        "BAY" => "Bayern",
        "B" => "Berlin",
        "BRA" => "Brandenburg",
        "BRE" => "Bremen",
        "HH" => "Hamburg",
        "HES" => "Hessen",
        "MV" => "Mecklenburg-Vorpommern",
        "NS" => "Niedersachsen",
        "NRW" => "Nordrhein-Westfalen",
        "RPF" => "Rheinland-Pfalz",
        "SAA" => "Saarland",
        "SAC" => "Sachsen",
        "SAH" => "Sachsen-Anhalt",
        "SH" => "Schleswig-Holstein",
        "TH" => "Thüringen"
    }
    VCR.use_cassette 'courts/homepage' do
      expect(subject.states).to eq(types)
    end
  end

  context "entry counts" do
    context "Bundesgerichte" do
      it "should find all Bundesgerichte" do
        VCR.use_cassette 'courts/all_brd' do
          contacts = subject.contacts_for('BRD')
          #ap contacts
          expect(contacts.count).to eq(12)
        end
      end
    end


    context "NRW" do
      it "should find all NRW" do
        VCR.use_cassette 'courts/all_nrw' do
          contacts = subject.contacts_for('NRW')
          #ap contacts
          expect(contacts.count).to eq(377)
        end
      end
    end

    context "search all" do
      it "should find all entries" do
        VCR.use_cassette 'courts/all_all' do
          original = {
              "BRD" => "Bundesgerichte/-behörden 12",
              "BW" => "Baden-Württemberg 284",
              "BAY" => "Bayern 263",
              "B" => "Berlin 38",
              "BRA" => "Brandenburg 64",
              "BRE" => "Bremen 19",
              "HH" => "Hamburg 35",
              "HES" => "Hessen 115",
              "MV" => "Mecklenburg-Vorpommern 55",
              "NS" => "Niedersachsen 262",
              "NRW" => "Nordrhein-Westfalen 377",
              "RPF" => "Rheinland-Pfalz 101",
              "SAA" => "Saarland 32",
              "SAC" => "Sachsen 79",
              "SAH" => "Sachsen-Anhalt 69",
              "SH" => "Schleswig-Holstein 58",
              "TH" => "Thüringen 63"
          }
          states = subject.states
          total = 0
          states.keys.each do |state|
            count = subject.contacts_for(state).count
            states[state] += " #{count}"
            total += count
          end
          expect(states).to eq(original)
          expect(total).to eq(1926)
        end
      end
    end
  end

  context "id" do
    it "dumps non-unique ids" do
      msg = []
      VCR.use_cassette 'courts/all_all' do
        subject.contacts.inject({}) do |memo, c|
          k = c.id
          if memo.has_key?(k)
            msg << "#{memo[k]}\n#{c}"
          else
            memo[k] = c
          end
          memo
        end
        expect(msg).to eq([])
      end
    end

    it "should have unique court names" do
      VCR.use_cassette 'courts/all_all' do
        ids = subject.contacts.map(&:id)
        expect(ids.uniq.length).to eq(ids.length)
      end
    end
  end


  context "contact details" do
    it "parses first url from multiple" do
      VCR.use_cassette 'courts/sg_b' do
        contacts = subject.contacts_of_type('SG', 'B')
        expect(contacts.length).to eq(2)
        expect(contacts.first.url).to eq('http://www.berlin.de/lsg')
      end
    end

    it "should have full location addresses" do
      VCR.use_cassette 'courts/all_all' do
        failed = false
        subject.contacts.each do |contact|
          a = contact.location_address
          unless a.street && a.plz && a.city
            ap a
            failed = true
          end
        end
        expect(failed).to eq(false)
      end
    end

    it "should have plz & city post addresses" do
      VCR.use_cassette 'courts/all_all' do
        failed = false
        subject.contacts.each do |contact|
          a = contact.location_address
          unless a.plz && a.city
            ap a
            failed = true
          end
        end
        expect(failed).to eq(false)
      end
    end

    xit "dumps contact in csv format" do
      require 'csv'
      VCR.use_cassette 'courts/all_all' do
        CSV.open("address.csv", "wb") do |csv|
          subject.contacts.each do |c|
            l = c.location_address
            p = c.post_address
            csv << [c.justiz_id, c.court,
                    l.street, l.plz, l.city,
                    p.street, p.plz, p.city,
                    c.phone, c.fax, c.email, c.url]
          end
        end
      end
    end

    it "should return Address" do
      VCR.use_cassette 'courts/all_brd' do
        contact = subject.contacts_for('BRD').first
        expect(contact.location_address).to be_a(Justiz::Address)
        expect(contact.post_address).to be_a(Justiz::Address)
      end
    end

    it "should rename court" do
      VCR.use_cassette 'courts/zvg_nrw' do
        contact = subject.contacts_of_type('ZVG', 'NRW').first
        expect(contact.court).to_not match(/Zwangsversteigerung/)
      end
    end
  end
end


