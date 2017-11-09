Observatory::App.controllers :player_data_exports, parent: :player do
  get :show, map: 'exports/:id' do |_, id|
    @export = get_or_404(PlayerDataExport, id)

    render 'show'
  end

  get :download, map: 'exports/:id/download' do |_, id|
    @export = get_or_404(PlayerDataExport, id)

    unless @export.success? && File.exist?(@export.file_path)
      raise Sinatra::NotFound
    end

    send_file @export.file_path, filename: File.basename(@export.file_path)
  end
end
