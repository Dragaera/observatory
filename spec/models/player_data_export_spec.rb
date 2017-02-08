require 'spec_helper'

RSpec.describe PlayerDataExport do
    describe '#export_csv' do
        let(:player) { create(:player) }
        let(:data1) do
          build(
            :player_data_point,
            created_at: Time.utc(2017, 1, 1, 10, 0, 0),
            adagrad_sum: 1.0,
            alias: 'John',
            experience: 10,
            hive_player_id: 1,
            level: 5,
            reinforced_tier: nil,
            score: 125,
            skill: 50,
            time_total: 200,
            time_alien: 70,
            time_marine: 130,
            time_commander: 20,
          )
        end
        let(:data2) do
          build(
            :player_data_point,
            created_at: Time.utc(2017, 1, 2, 10, 0, 0),
            adagrad_sum: 2.0,
            alias: 'George',
            experience: 30,
            hive_player_id: 1,
            level: 7,
            reinforced_tier: 'silver',
            score: 250,
            skill: 70,
            time_total: 500,
            time_alien: 270,
            time_marine: 230,
            time_commander: 50,
          )
        end

        before(:each) do
          player.add_player_data_point(data1)
          player.add_player_data_point(data2)
        end

      it "writes a CSV document containing all the user's data" do
        expected = <<EOF
created_at,adagrad_sum,alias,experience,hive_player_id,level,reinforced_tier,score,skill,time_total,time_alien,time_marine,time_commander,relevant
2017-01-01T10:00:00+00:00,1.0,John,10,1,5,,125,50,200,70,130,20,true
2017-01-02T10:00:00+00:00,2.0,George,30,1,7,silver,250,70,500,270,230,50,true
EOF

        io = StringIO.new
        export = create(:player_data_export, player: player)
        export.create_csv(io: io)
        expect(io.string).to eq expected
      end

      context 'if writing data is successful' do
        it 'sets the status to success if all went well' do
          io = StringIO.new
          export = create(:player_data_export, player: player)
          expect { export.create_csv(io: io) }.to change { export.status }.to(PlayerDataExport::STATUS_SUCCESS)
        end
      end

      context 'if writing data fails' do
        it 'sets the status to error, and sets the error message' do
          # TODO: Unsure how to do this, as I have no way of reliably knowing
          # which methods of the IO object CSV calls under the hood.
          # io = StringIO.new
          # allow(io).to receive(:<<).and_raise(IOError, 'IO is hard!')

          # export = create(:player_data_export, player: player)
          # expect { export.create_csv(io: io) }.to(
          #   change { export.status }.to(PlayerDataExport::STATUS_ERROR).and(
          #     change { export.error_message }.to 'IO is hard!')
          # )
        end
      end
    end
end
