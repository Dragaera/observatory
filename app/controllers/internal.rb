Observatory::App.controllers :internal do
  STATUS_OK = 'OK'
  STATUS_CONNECTED = 'CONNECTED'
  STATUS_ERROR = 'ERROR'

  get :health, map: '/health' do
    content_type :json
    http_status = 200

    data = {
      status: STATUS_OK,
      database: check_db_connectivity ? STATUS_OK : STATUS_ERROR,
      services: {
        hive: check_service_connectivity('hive2.ns2cdt.com', 80) ? STATUS_CONNECTED : STATUS_ERROR,
      }
    }

    if data[:database] != STATUS_OK
      data[:status] = STATUS_ERROR
      http_status = 503
    end

    [http_status, {}, data.to_json]
  end

end
