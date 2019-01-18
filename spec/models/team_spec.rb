require 'spec_helper'

describe SlackRubyBotServer::Team do
  context '#find_or_create_from_env!' do
    before do
      ENV['SLACK_API_TOKEN'] = 'token'
    end
    context 'team', vcr: { cassette_name: 'team_info' } do
      it 'creates a team' do
        expect { SlackRubyBotServer::Team.find_or_create_from_env! }.to change(SlackRubyBotServer::Team, :count).by(1)
        team = SlackRubyBotServer::Team.first
        expect(team.team_id).to eq 'T04KB5WQH'
        expect(team.name).to eq 'dblock'
        expect(team.domain).to eq 'dblockdotorg'
        expect(team.token).to eq 'token'
      end
    end
    after do
      ENV.delete 'SLACK_API_TOKEN'
    end
  end
  context '#purge!' do
    let!(:active_team) { Fabricate(:team) }
    let!(:inactive_team) { Fabricate(:team, active: false) }
    let!(:inactive_team_a_week_ago) { Fabricate(:team, updated_at: 1.week.ago, active: false) }
    let!(:inactive_team_two_weeks_ago) { Fabricate(:team, updated_at: 2.weeks.ago, active: false) }
    let!(:inactive_team_a_month_ago) { Fabricate(:team, updated_at: 1.month.ago, active: false) }
    it 'destroys teams inactive for two weeks' do
      expect do
        SlackRubyBotServer::Team.purge!
      end.to change(SlackRubyBotServer::Team, :count).by(-2)
      expect(SlackRubyBotServer::Team.where(id: active_team.id).first).to eq active_team
      expect(SlackRubyBotServer::Team.where(id: inactive_team.id).first).to eq inactive_team
      expect(SlackRubyBotServer::Team.where(id: inactive_team_a_week_ago.id).first).to eq inactive_team_a_week_ago
      expect(SlackRubyBotServer::Team.where(id: inactive_team_two_weeks_ago.id).first).to be nil
      expect(SlackRubyBotServer::Team.where(id: inactive_team_a_month_ago.id).first).to be nil
    end
  end
end
