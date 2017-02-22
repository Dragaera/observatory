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

  post :edit, map: '/update_frequencies/:id/edit' do
    frequency = get_or_404(UpdateFrequency, params['id'])
    data = params['update_frequency']
    frequency.update(
      name: data.fetch('name'),
      threshold: data.fetch('threshold'),
      interval: data.fetch('interval'),
      enabled: to_bool(data.fetch('enabled')),
      fallback: to_bool(data.fetch('fallback')),
    )

    redirect(url(:update_frequencies, :index))
  end
end
