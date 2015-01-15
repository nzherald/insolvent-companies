require 'bundler'
Bundler.require

include Capybara::DSL
Capybara.default_driver = :selenium

def print_out_company_names
  within('.dataList') do
    all('tr span.entityName').each do |name|
      puts name.text
    end
  end
end

visit 'http://www.business.govt.nz/companies/app/ui/pages/companies/search?advancedPanel=true'

within '#standardSearchCriteriaPanel' do
  fill_in 'q', with: ''
end

page.execute_script('$("#aEntityStatusGroups .main").click();')

check 'entityStatusGroup_EXTERNAL_ADMINISTRATION'
click_on 'advancedSearchButton'

sleep 2

loop do
  print_out_company_names
  next_pagination_link = all('.pagingNext').first
  within next_pagination_link do
    click_on 'Next'
  end
end
