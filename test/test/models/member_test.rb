require 'test_helper'

class MemberTest < ActiveSupport::TestCase

  context "a member" do

    setup do
      Account.set_current_account( accounts( :account_1 ).id )
      @member = members(:quentin_1)
    end

    # validate multi-accounting structure
    should have_db_column(:account_id)
    should "define the current account" do
      assert  Thread.current[:account_id]
    end
    should "match the current account" do
      a_member = Member.first
      assert_equal  a_member.account_id, Thread.current[:account_id]
    end

    # validate the model
    should belong_to( :user )
    should have_many( :posts )
    should have_many( :zines ).through( :posts )
    should have_many( :team_assets )
    should have_many( :teams ).through( :team_assets )

    # validate specific member methods
    should 'create new member for new admin' do
      # setup new world
      account = Account.create_new_account(
        {name:   "Mangoland"},
        {email:  "billybob@bob.com"},
        {coupon: "FreeTrial"}
      )
      assert account.errors.empty?
      Account.set_current_account( account )  # change world to new account

      # setup new user
      user = User.new(email: "limesublime@example.com")
      assert user.save_and_invite_member
      assert user.errors.empty?

      # setup new member
      member = nil
      assert_nothing_raised  {
        member = Member.create_org_admin( user )
        assert  member.errors.empty?
      }

      assert_equal  Member::DEFAULT_ADMIN[:first_name],member.first_name
      assert_equal  Member::DEFAULT_ADMIN[:last_name],member.last_name
      assert_equal  account.id, member.account_id
      assert_equal  user.member,member

    end   # should do

    should 'create new member for existing account' do
      account = accounts( :account_1 )
      user = users( :quentin )
      member = Member.create_new_member( user, {last_name: 'Blue', first_name: 'Wild'} )
      assert  member.errors.empty?
      assert_equal  account.id, member.account_id
      assert_equal  user.member,member
    end  # should do

    should "not get any non-world member" do
      x = users(:demarcus)
      assert   x.member.nil?
    end

  end   # context member

end #   class member
