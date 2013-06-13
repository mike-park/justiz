module Justiz
  module Scraper
    class Courts

      def court_types
        select_options(home_page, 'gerausw')
      end

      def states
        select_options(home_page, 'landausw')
      end

      def scrape(court_type, state)
        page = load_page(court_type, state)
        # if we reach limit on ALL, query each subtype
        if court_type == 'ALL' && limit_warning?(page)
            court_types.map do |court_type, description|
              next if court_type == 'ALL'
              page = load_page(court_type, state)
              if limit_warning?(page)
                puts(STDERR, "Warning: State #{state} has too many contacts of #{description}[#{court_type}]")
              end
              parse_page(page)
            end.flatten.compact.uniq
        else
          parse_page(page)
        end
      end

      private

      def home_page
        @home_page ||= agent.get('http://www.justizadressen.nrw.de/og.php?MD=nrw')
      end

      def load_page(court_type, state)
        form = home_page.forms[2]
        form['gerausw'] = court_type
        form['landausw'] = state
        agent.submit(form, form.buttons_with(name: 'suchen1').first)
      end

      def agent
        @agent ||= Justiz::Scraper::Agent.new
      end

      def parse_page(page)
        rows = page.search('tr').map { |tr| tr.search('td').to_a }
        contact_rows = rows.find_all { |row| row.length == 3 }
        contact_rows.map do |court, addresses, phones|
          addresses = AddressTd.new(addresses)
          phones = AddressTd.new(phones)

          Justiz::Contact.new.merge court: court.text.strip,
                                    location: addresses.lieferanschrift,
                                    post: addresses.postfach,
                                    phone: phones.telefone,
                                    fax: phones.fax,
                                    justiz_id: phones.justiz_id,
                                    url: phones.url,
                                    email: phones.email
        end
      end

      def limit_warning?(page)
        # avoid invalid UTF-8 errors by force encoding.
        page.search('p').find {|p| p.text.force_encoding("ISO-8859-15") =~ /Ihre Suchanfrage ergab mehr als/i}
      end

      def select_options(page, name)
        page.search("[name='#{name}'] > option").inject({}) do |memo, node|
          memo[node['value']] = node.text
          memo
        end
      end

      class AddressTd
        attr_reader :texts

        def initialize(node)
          nodes = node.children.to_a
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
end
