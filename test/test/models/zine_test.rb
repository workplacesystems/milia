require 'test_helper'

class ZineTest < ActiveSupport::TestCase

  context "a zine" do

    setup do
      Account.set_current_account( accounts( :account_2 ).id )
      @zine = Zine.first
    end

    # validate multi-accounting structure
    should have_db_column(:account_id)
    should "match the current account" do
      assert_equal  @zine.account_id, Thread.current[:account_id]
    end

    # validate the model
    should have_many( :posts )
    should belong_to( :team )
    should have_many( :members ).through( :posts )

    # validate the particular associations in the model
    should 'find members through posts' do
      assert_equal 2, zines( :zine_2_b ).members.count
    end  #should do

    should 'find posts' do
      assert_equal 3, zines( :zine_2_a ).posts.count
    end  #should do

    should 'match a zine with account' do
      assert_equal  2,zines( :zine_2_a ).account_id
    end  # should do



  end   # context zine

end # class ZineTest
