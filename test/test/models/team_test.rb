require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  context "a team" do

    setup do
      Account.set_current_account( accounts( :account_2 ).id )
      @team = Team.first
    end


    # validate multi-accounting structure
    should have_db_column(:account_id)
    should "match the current account" do
      assert_equal  @team.account_id, Thread.current[:account_id]
    end

    should have_many( :team_assets )
    should have_many( :team_members ).through( :team_assets )

    should have_many( :zines )
    should have_many( :posts ).through( :zines )

    # validate the particular associations in the model
    should 'find team members through teams' do
      assert_equal 2, teams( :team_2_b ).team_members.count
    end  #should do

    should 'find posts' do
      assert_equal 3, teams( :team_2_a ).posts.count
    end  #should do

    should 'match a team with account' do
      assert_equal  2,teams( :team_2_b ).account_id
    end  # should do

    should 'check team assets' do
      assert_equal  2, teams( :team_2_a ).team_assets.count
    end  # should do

    should 'check zines' do
      assert_equal  1, teams( :team_2_b ).zines.count
    end  # should do


  end   # context team

end # team
