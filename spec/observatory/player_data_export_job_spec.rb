require 'stringio'

require 'spec_helper'

module Observatory
  RSpec.describe PlayerDataExportJob do
    describe '::perform' do
      it "writes a CSV document containing all the user's data" do
        player = create(:player)
        data1 = build(
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
        data2 = build(
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

        player.add_player_data_point(data1)
        player.add_player_data_point(data2)

        expected = <<EOF
created_at,adagrad_sum,alias,experience,hive_player_id,level,reinforced_tier,score,skill,time_total,time_alien,time_marine,time_commander,relevant
2017-01-01T10:00:00+00:00,1.0,John,10,1,5,,125,50,200,70,130,20,true
2017-01-02T10:00:00+00:00,2.0,George,30,1,7,silver,250,70,500,270,230,50,true
EOF

        io = StringIO.new
        Observatory::PlayerDataExportJob.perform(player.id, io: io)
        expect(io.string).to eq expected
      end
    end
  end
end
