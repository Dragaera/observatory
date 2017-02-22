Observatory::App.controllers :update_frequencies do
  before do
    authenticate!
  end

  get :index do
    @frequencies = UpdateFrequency.order(:interval)
    render 'index'
  end

  get :new do
    @frequency = session['update_frequency'] || UpdateFrequency.new(enabled: true)
    session.delete 'update_frequency'

    render 'new'
  end

  post :new do
    obj_params = params.fetch('update_frequency')

    frequency = UpdateFrequency.new(obj_params)
    frequency.save
    redirect(url(:update_frequencies, :index))
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

  post :delete, map: '/update_frequencies/:id/delete' do
    frequency = get_or_404(UpdateFrequency, params['id'])
    frequency.destroy
    redirect(url(:update_frequencies, :index))
  end
end
