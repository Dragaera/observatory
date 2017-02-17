Observatory::App.controllers :player_data_exports, parent: :player do
  get :show, map: 'exports/:id' do |player_id, id|
    player  = get_or_404(Player, player_id)
    @export = get_or_404(player.player_data_exports_dataset, id)

    render 'show'
  end

  get :download, map: 'exports/:id/download' do |player_id, id|
    @export = get_or_404(PlayerDataExport, id)

    unless @export.success? && File.exists?(@export.file_path)
      raise Sinatra::NotFound
    end

    send_file @export.file_path, filename: File.basename(@export.file_path)
  end
end
