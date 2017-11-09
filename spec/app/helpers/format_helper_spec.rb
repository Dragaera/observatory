require 'spec_helper'

RSpec.describe "Observatory::App::FormatHelperHelper" do
  let(:helpers){ Class.new }
  before { helpers.extend Observatory::App::FormatHelperHelper }
  subject { helpers }
end
