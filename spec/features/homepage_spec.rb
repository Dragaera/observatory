require 'spec_helper'

feature 'Visiting the home page' do
  background do
    visit '/'
  end

  it 'redirects me to /query' do
    expect(page).to have_current_path('/query')
  end

  it 'shows a form to query for player data' do
    expect(page).to have_content 'Query data of player'
  end
end
