Observatory::App.controllers :update_frequencies do
  before do
    authenticate!
  end

  get :index do
    @frequencies = UpdateFrequency.order(:interval)
    render 'index'
  end

  get :edit, map: '/update_frequencies/:id/edit' do
    @frequency = get_or_404(UpdateFrequency, params['id'])

    render 'edit'
  end

end
