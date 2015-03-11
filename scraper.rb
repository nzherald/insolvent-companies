require 'bundler'
Bundler.require

module InsolventCompanies
  Company = Struct.new(:name, :details)

  class Scraper
    include Capybara::DSL
    attr_reader :years, :results

    def initialize
      Capybara.app = self
      Capybara.current_driver = :mechanize
      Capybara.run_server = false
      Capybara.app_host = "http://www.parliament.nz"
      @results = []
      @years = 1900...2016
    end

    def scrape!
      years.each do |year|
        url = "http://www.business.govt.nz/companies/app/ui/pages/companies/search?q=&entityTypes=ALL&entityStatusGroups=EXTERNAL_ADMINISTRATION&incorpFrom=01%2F01%2F#{year}&incorpTo=01%2F01%2F#{year + 1}&addressTypes=ALL&start=0&limit=15&sf=&sd=&advancedPanel=true&mode=advanced#results"
        puts url
        visit url

        iterate_through_results
      end

      results
    end

    private

    def extract_company_details
      return unless data_list = first('.dataList')
      within(data_list) do
        all('tr a.link').each do |record|
          name = record.find('.entityName').text
          details = record.find('.entityInfo').text
          puts name
          results << Company.new(name, details)
        end
      end
    end

    def iterate_through_results
      loop do
        extract_company_details
        break unless next_pagination_link = first('.pagingNext a')

        next_pagination_link.click
      end
    end

  end
end

InsolventCompanies::Scraper.new.scrape!
