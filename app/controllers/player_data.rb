Observatory::App.controllers :player_data do

  get :index, map: '/' do
    render 'index'
  end

end
