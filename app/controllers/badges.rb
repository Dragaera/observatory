Observatory::App.controllers :badges do
  get :index do
    @badge_groups = BadgeGroup.order(Sequel.asc(:sort))

    render 'index'
  end
end
