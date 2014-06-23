require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  context "a post" do

    setup do
      Account.set_current_account( accounts( :account_1 ).id )
      @zine = Zine.first
    end

    # validate multi-accounting structure
    should have_db_column(:account_id)
    should "match the current account" do
      assert_equal  @zine.account_id, Thread.current[:account_id]
    end

    # validate the model
    should belong_to( :member )
    should belong_to( :zine )
    should have_one(:team).through(:zine)

    # model-specific tests
    should "get all posts within account" do
      assert_equal 7, Post.count
    end

    should "get only member posts in account" do
      Account.set_current_account( accounts( :account_2 ).id )

      x = members(:quentin_2)
      assert_equal 2, x.posts.size
    end

    should "see jermaine in two accounts with dif posts" do
      jermaine = users( :jermaine )
      Account.set_current_account( accounts( :account_2 ).id )
      assert_equal   1, jermaine.member.posts.size

      Account.set_current_account( accounts( :account_3 ).id )
      jermaine.reload
      assert_equal   6, jermaine.member.posts.size
    end

    should "get all team posts" do
      Account.set_current_account( accounts( :account_2 ).id )
      team = teams( :team_2_b )
      assert_equal  2, team.posts.size
    end

    should 'match team in a post' do
      Account.set_current_account( accounts( :account_2 ).id )
      assert_equal  posts(:post_plum_2_1_b).team, teams(:team_2_b)
    end  # should do

    should 'match a posts zine with account' do
      Account.set_current_account( accounts( :account_2 ).id )
      assert_equal  2,posts(:post_plum_2_1_b).zine.account_id
    end  # should do

  end   # context post

  # _____________________________________________________________________________

end  # class test
