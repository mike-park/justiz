# encoding: utf-8

require 'rspec'
require 'justiz'
require 'awesome_print'

describe Justiz::Scraper::Courts do
  it "should have court types" do
    types = {
        "ALL" => "-- alle Gerichte/Behörden --",
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
    expect(subject.court_types).to eq(types)
  end

  it "should have states" do
    types = {
        "ALL" => "-- Auswahl über PLZ/Ort --",
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
    expect(subject.states).to eq(types)
  end

  context "Bundesgerichte" do
    it "should find all Bundesgerichte" do
      contacts = subject.scrape('ALL', 'BRD')
      #ap contacts
      expect(contacts.count).to eq(12)
    end
  end


  context "NRW" do
    it "should find all NRW" do
      contacts = subject.scrape('ALL', 'NRW')
      #ap contacts
      expect(contacts.count).to eq(513)
    end
  end

  context "search all" do
    it "should find all entries" do
      # as of 13.6.2013
      original = {
          "ALL" => "-- Auswahl über PLZ/Ort -- 0",
          "BRD" => "Bundesgerichte/-behörden 12",
          "BW" => "Baden-Württemberg 430",
          "BAY" => "Bayern 348",
          "B" => "Berlin 38",
          "BRA" => "Brandenburg 64",
          "BRE" => "Bremen 19",
          "HH" => "Hamburg 35",
          "HES" => "Hessen 115",
          "MV" => "Mecklenburg-Vorpommern 55",
          "NS" => "Niedersachsen 305",
          "NRW" => "Nordrhein-Westfalen 513",
          "RPF" => "Rheinland-Pfalz 101",
          "SAA" => "Saarland 32",
          "SAC" => "Sachsen 79",
          "SAH" => "Sachsen-Anhalt 69",
          "SH" => "Schleswig-Holstein 58",
          "TH" => "Thüringen 63"
      }
      states = subject.states
      states.keys.each do |state|
        count = subject.scrape('ALL', state).count
        states[state] += " #{count}"
      end
      expect(states).to eq(original)
    end
  end
end

