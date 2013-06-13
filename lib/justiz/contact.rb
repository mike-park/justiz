require 'awesome_print'

module Justiz
  class Contact
    def gerichte(type, bundesland)
      page = agent.get('http://www.justizadressen.nrw.de/og.php?MD=nrw')
      form = page.forms[2]
      form['gerausw'] = type
      form['landausw'] = bundesland
      page = agent.submit(form, form.buttons_with(name: 'suchen1').first)
      ap page
      page.search('table').map { |t| puts t.text }
      contacts = []
      page.search('tr').each do |tr|
        tds = tr.search('td').to_a
        next if tds.empty?
        contact = {}
        contact[:gericht] = tds[0].text.strip

        td = AddressTd.new(tds[1])
        contact[:leifer] = td.lieferanschrift
        contact[:post] = td.postfach

        td = AddressTd.new(tds[2])
        contact[:phone] = td.telefone
        contact[:fax] = td.fax
        contact[:justiz_id] = td.justiz_id
        contact[:url] = td.url
        contact[:email] = td.email

        contacts.push contact
      end
      contacts
    end

    private

    def agent
      @agent ||= Justiz::Agent.new
    end

    class AddressTd
      attr_reader :nodes, :texts

      def initialize(node)
        @nodes = node.children.to_a
        @texts = nodes.map { |n| n.text.strip }.find_all { |t| !blank?(t) }
      end

      def telefone
        same_line('Telefon:')
      end

      def fax
        same_line('Fax:')
      end

      def justiz_id
        same_line('XJustiz-ID:')
      end

      def lieferanschrift
        next_line('Lieferanschrift')
      end

      def postfach
        next_line('Postanschrift')
      end

      def url
        next_line('URL')
      end

      def email
        next_line('Mail')
      end

      private

      def blank?(something)
        something.to_s !~ /[^[:space:]]/
      end

      def next_line(name)
        reg = Regexp.new(name, true)
        line = texts.find_index { |text| text.match(reg) }
        line && texts[line + 1]
      end

      def same_line(name)
        reg = Regexp.new("#{name}(.*)", true)
        text = texts.map { |t| t.match(reg) }.compact.first
        text = text[1].strip if text
        text if !blank?(text)
      end
    end
  end
end