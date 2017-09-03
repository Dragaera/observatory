Observatory::App.controllers :api_keys do
  before do
    authenticate!
  end

  get :index do
    @api_keys = APIKey.all

    render 'index'
  end

  get :show do
    @api_key = get_or_404(APIKey, params.fetch('id').to_i)

    render 'show'
  end

  get :new do
    @api_key = APIKey.new(active: true)

    render 'new'
  end

  post :new do
    obj_params = params.fetch('api_key')

    key = APIKey.generate(save: false)
    key.update(
      description: obj_params['description'],
      active:      to_bool(obj_params['active'])
    )
    key.save
    redirect(url(:api_keys, :index))
  end

  get :edit, map: '/api_keys/:id/edit' do
    @api_key = get_or_404(APIKey, params.fetch('id').to_i)

    render 'edit'
  end

  post :edit, map: '/api_keys/:id/edit' do
    api_key = get_or_404(APIKey, params.fetch('id').to_i)

    obj_params = params.fetch('api_key')
    api_key.update(
      description: obj_params.fetch('description'),
      active:      to_bool(obj_params.fetch('active'))
    )

    redirect(url(:api_keys, :index))
  end

  post :delete, map: '/api_keys/:id/delete' do
    api_key = get_or_404(APIKey, params.fetch('id').to_i)
    api_key.destroy

    redirect(url(:api_keys, :index))
  end
end
