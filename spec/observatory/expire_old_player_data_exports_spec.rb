require 'stringio'

require 'spec_helper'

module Observatory
  RSpec.describe PlayerDataExportJob do
    describe '::perform' do
      let!(:export_1) { create(:player_data_export, created_at: Time.new(2017, 1, 1), status: PlayerDataExport::STATUS_SUCCESS) }
      let!(:export_2) { create(:player_data_export, created_at: Time.new(2017, 1, 2), status: PlayerDataExport::STATUS_SUCCESS) }
      let!(:export_3) { create(:player_data_export, created_at: Time.new(2017, 1, 5), status: PlayerDataExport::STATUS_SUCCESS) }

      it'expires old exports' do
        Timecop.travel(Time.new(2017, 1, 10)) do
          ExpireOldPlayerDataExports.perform
          [export_1, export_2, export_3].map(&:reload)
          expect(export_1).to be_expired
          expect(export_2).to be_expired
          expect(export_3).to_not be_expired
        end
      end

      it 'deletes files of exired reports' do
        t = Tempfile.new
        export_1.update(file_path: t.path)

        Timecop.travel(Time.new(2017, 1, 10)) do
          ExpireOldPlayerDataExports.perform
        end

        expect(File).to_not exist(t.path)
      end
    end
  end
end
