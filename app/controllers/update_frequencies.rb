Observatory::App.controllers :update_frequencies do
  get :index do
    @frequencies = UpdateFrequency.order(:interval)
    render 'index'
  end

  get :show, map: '/update_frequencies/:id' do
  end
end
