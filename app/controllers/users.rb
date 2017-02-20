Observatory::App.controllers :users do
  before do
    authenticate!
  end

  get :index do
    @users = User.order(:user)
    render 'index'
  end

  get :new do
    @user = session['user'] || User.new(active: true)
    session.delete 'user'

    render 'new'
  end

  post :new do
    obj_params = params.fetch('user')

    password_confirm = obj_params.delete('password_confirm')
    if obj_params.key? 'active'
      obj_params['active'] = to_bool(obj_params['active'])
    end
    user = User.new(obj_params)

    password_errors = []
    if obj_params['password'] != password_confirm
      password_errors << 'Password: Did not match confirmation'
    end

    if user.valid? && password_errors.empty?
      user.save
      redirect(url(:users, :index),
               success: "Created user #{ user.user }")
    else
      # TODO: Marshal
      # Reset password - otherwise we'd end up with the hash prefilled in the form.
      user.password = nil
      session['user'] = user
      redirect(url(:users, :new),
              form_error: pp_form_errors(user.errors) + password_errors)
    end
  end

  get :show, map: '/users/:id' do
    @user = get_or_404(User, params.fetch('id').to_i)
    render 'show'
  end

  get :edit, map: '/users/:id/edit' do
    @user = session['user'] || get_or_404(User, params.fetch('id').to_i)
    session.delete 'user'

    # Reset password - otherwise we'd end up with the hash prefilled in the form.
    @user.password = nil

    render 'edit'
  end

  post :edit, map: '/users/:id/edit' do
    user = get_or_404(User, params.fetch('id').to_i)

    obj_params = params.fetch('user')

    username         = obj_params['user']
    password         = obj_params['password']
    password_confirm = obj_params['password_confirm']

    # Password update if desired
    password_errors = []
    if password && !password.empty?
      if password == password_confirm
        user.password = password
      else
        password_errors << 'Password: Did not match confirmation'
      end
    end

    # Active update if desired
    user.active = to_bool(obj_params['active']) if obj_params.key? 'active'

    # User update if desired
    user.user = username if username && !username.empty?

    if user.valid? && password_errors.empty?
      user.save
      redirect(url(:users, :show, id: user.id),
               success: "Modified #{ user.user }")
    else
      # TODO: Marshal
      # Reset password - otherwise we'd end up with the hash prefilled in the form.
      user.password = nil
      session['user'] = user
      redirect(url(:users, :edit, id: user.id),
               form_error: pp_form_errors(user.errors) + password_errors)
    end
  end

  post :delete, map: '/users/:id/delete' do
    user = get_or_404(User, params.fetch('id').to_i)
    user.destroy
    redirect(url(:users, :index))
  end

  get :login, map: '/login' do
    render 'login'
  end

  post :login, map: '/login' do
    username = params['user']
    password = params['password']

    user = User.authenticate(username, password)
    if user
      user.update(last_signin_at: DateTime.now)
      session['login_user'] = user
      redirect('/')
    else
      redirect(url(:users, :login))
    end
  end

  get :logout, map: '/logout' do
    session.delete 'login_user'
    redirect(url(:users, :login))
  end
end
