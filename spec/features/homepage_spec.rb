require 'spec_helper'

feature 'Visiting the home page' do
  background do
    visit '/'
  end

  it 'shows a form to search for players' do
    expect(page).to have_content 'Search for player'
  end
end
