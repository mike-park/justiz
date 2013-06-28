module Justiz
  module Scraper
    class Courts

      def court_types
        home_page.options_of 'gerausw'
      end

      def states
        home_page.options_of 'landausw'
      end

      def contacts
        contacts = states.keys.map do |state|
          contacts_for(state)
        end.flatten.compact
        uniq_contacts(contacts)
      end

      def contacts_for(state)
        page = load_page('ALL', state)
        return page.contacts unless page.limit_warning?

        # do each type separately hoping to avoid limit warning
        contacts = court_types.keys.map do |court_type|
          contacts_of_type(court_type, state)
        end.flatten.compact
        uniq_contacts(contacts)
      end

      def contacts_of_type(type, state)
        contacts = load_page(type, state, with_warning: true).contacts
        uniq_contacts(contacts)
      end

      private

      def uniq_contacts(contacts)
        contacts.uniq {|contact| contact.digest }
      end

      def home_page
        @home_page ||= Page.new(agent.get('http://www.justizadressen.nrw.de/og.php?MD=nrw'))
      end

      def load_page(court_type, state, options = {})
        form = home_page.forms[2]
        form['gerausw'] = court_type
        form['landausw'] = state
        page = Page.new(agent.submit(form, form.buttons_with(name: 'suchen1').first))
        if options[:with_warning] && page.limit_warning?
          puts(STDERR, "Warning: State #{state} has too many contacts of #{court_type}")
        end
        page
      end

      def agent
        @agent ||= Justiz::Scraper::Agent.new
      end
    end

    class Page < SimpleDelegator
      def limit_warning?
        # avoid invalid UTF-8 errors by force encoding.
        search('p').find do |p|
          p.text.force_encoding("ISO-8859-15") =~ /Ihre Suchanfrage ergab mehr als/i
        end
      end

      # return hash of options of select field, exclude ALL value
      def options_of(name)
        search("[name='#{name}'] > option").inject({}) do |memo, node|
          memo[node['value']] = node.text unless node['value'] == 'ALL'
          memo
        end
      end

      def contacts
        @contacts ||= parse_contacts.uniq
      end

      def parse_contacts
        rows = search('tr').map { |tr| tr.search('td').to_a }
        contact_rows = rows.find_all { |row| row.length == 3 }
        contact_rows.map do |court, addresses, kontakt|
          addresses = AddressTd.new(addresses)
          kontakt = KontaktTd.new(kontakt)

          Justiz::Contact.new(court: court.text.strip,
                              location: addresses.lieferanschrift,
                              post: addresses.postfach,
                              phone: kontakt.telefone,
                              fax: kontakt.fax,
                              justiz_id: kontakt.justiz_id,
                              url: kontakt.url,
                              email: kontakt.email)
        end
      end

      class Td
        attr_reader :texts

        def initialize(node)
          nodes = node.children.to_a
          @texts = nodes.map { |n| n.text.strip }.find_all { |t| !blank?(t) }
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

      class AddressTd < Td
        def lieferanschrift
          next_line('Lieferanschrift')
        end

        def postfach
          next_line('Postanschrift')
        end
      end

      class KontaktTd < Td
        attr_reader :url

        def initialize(node)
          super
          if (a = node.search('a').first)
            @url = a['href']
          end
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

        def email
          next_line('Mail')
        end
      end
    end
  end
end
