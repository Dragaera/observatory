require 'securerandom'
##
# This file mounts each app in the Padrino project to a specified sub-uri.
# You can mount additional applications using any of these commands below:
#
#   Padrino.mount('blog').to('/blog')
#   Padrino.mount('blog', :app_class => 'BlogApp').to('/blog')
#   Padrino.mount('blog', :app_file =>  'path/to/blog/app.rb').to('/blog')
#
# You can also map apps to a specified host:
#
#   Padrino.mount('Admin').host('admin.example.org')
#   Padrino.mount('WebSite').host(/.*\.?example.org/)
#   Padrino.mount('Foo').to('/foo').host('bar.example.org')
#
# Note 1: Mounted apps (by default) should be placed into the project root at '/app_name'.
# Note 2: If you use the host matching remember to respect the order of the rules.
#
# By default, this file mounts the primary app which was generated with this project.
# However, the mounted app can be modified as needed:
#
#   Padrino.mount('AppName', :app_file => 'path/to/file', :app_class => 'BlogApp').to('/')
#

##
# Setup global project settings for your apps. These settings are inherited by every subapp. You can
# override these settings in the subapps as needed.
#
Padrino.configure_apps do
  # enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET', SecureRandom.hex(64))
  set :protection, :except => :path_traversal
  # TODO: On Chrome, when using nginx as a reverse proxy, the CSRF token -
  # albeit present in the cookie - does not get carried over into the sessions
  # object. Any other browsers, or accessing the application directly, works
  # fine.
  # As CSRF protection is not absolutely mandatory for this application - any
  # information is public, and no damaging actions can be taken - it will be
  # disabled until the bug is fixed.
  set :protect_from_csrf, false
end

# Mounts the core application for this project
Padrino.mount('Observatory::App', :app_file => Padrino.root('app/app.rb')).to('/')
