require 'test_helper'
 
# #############################################################################
# Note: this tests not only the methods in models/account.rb but
# also all of the milia-injected methods from base.rb
# #############################################################################
 
class AccountTest < ActiveSupport::TestCase


  context "a account" do

# ------------------------------------------------------------------------
    setup do
      @account =accounts( :account_1 )
      Account.set_current_account( @account.id )
    end

# #############################################################################
# #############################################################################
# ------------------------------------------------------------------------
# validate multi-accounting structure
# ------------------------------------------------------------------------
    should have_db_column(:account_id)
    should have_db_column(:name)
    should have_many( :posts )
    should have_many( :zines )
    should have_many( :team_assets )
    should have_many( :teams )
    should have_many( :members )
    should have_and_belong_to_many( :users )

# ------------------------------------------------------------------------
# validate account creation callbacks, validators
# ------------------------------------------------------------------------
    should 'have a new_signups_not_permitted' do
      assert Account.respond_to? :new_signups_not_permitted?
      assert !Account.new_signups_not_permitted?( {} )
    end  # should do

    should 'create new account' do

      assert_difference( 'Account.count' ) do
          # setup new world
        account = Account.create_new_account( 
              {name:   "Mangoland"}, 
              {email:  "billybob@bob.com"}, 
              {coupon: "FreeTrial"}
        )
        assert_not_nil   account
        assert_kind_of   Account,account
        assert account.errors.empty?
        assert_equal  "Mangoland", account.name
      end 

    end  # should do
        
    should 'account signup callback' do 
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
      assert_difference( 'Member.count' ) do
        assert_nothing_raised  { 
          member = Account.account_signup(user, account)
          assert  member.errors.empty?
        }
      end  # new Member DB records created

      assert_equal  Member::DEFAULT_ADMIN[:first_name],member.first_name
      assert_equal  Member::DEFAULT_ADMIN[:last_name],member.last_name
      assert_equal  account.id, member.account_id
      assert_equal  user.member,member
       
    end  # should do
        
# #############################################################################
# ####  acts_as_universal_and_determines_account injected methods  #############
# #############################################################################
        
    should 'current_account_id - non nil' do
      tid = Account.current_account_id
      assert_kind_of  Integer,tid
      assert_equal  accounts( :account_1 ).id,tid
    end  # should do
        
    should 'current_account - nil' do
         # force the current_account to be nil
      Thread.current[:account_id] = nil
         
      account = Account.current_account
      assert_nil  account
      
    end  # should do
        
    should 'current_account - valid tid' do
      account = Account.current_account
      assert_kind_of  Account,account
      assert_equal  accounts( :account_1 ),account
    end  # should do
        
    should 'current_account - invalid tid' do
         # force the current_account to be nil
      Thread.current[:account_id] = 500

      assert_nothing_raised  { 
        assert_nil  Account.current_account
      }

    end  # should do
         
    should 'set current account - account obj' do
      assert_equal  accounts( :account_1 ).id, Account.current_account_id
      Account.set_current_account( accounts( :account_3 ) )
      assert_equal  accounts( :account_3 ).id, Account.current_account_id
    end  # should do
         
    should 'set current account - account id' do
      assert_equal  accounts( :account_1 ).id, Account.current_account_id
      Account.set_current_account( accounts( :account_3 ).id )
      assert_equal  accounts( :account_3 ).id, Account.current_account_id
    end  # should do
         
    should 'NOT set current account - invalid arg' do
      assert_equal  accounts( :account_1 ).id, Account.current_account_id
      assert_raise(ArgumentError) { 
        Account.set_current_account( '2' )
      }
      assert_equal  accounts( :account_1 ).id, Account.current_account_id
    end  # should do

RESTRICT_SNIPPET = 'posts.account_id = 1 AND zines.account_id = 1'
    should 'prepare a restrict account snippet' do
      assert_equal RESTRICT_SNIPPET, Account.where_restrict_account( Post, Zine )
    end  # should do

    should 'clear account.users when account destroyed' do
      target = accounts(:account_2)
      Account.set_current_account( target )
      quentin = users(:quentin)
      assert_equal 2,quentin.accounts.count

      assert_difference( "Account.count", -1 ) do
        target.destroy
      end 

      quentin.reload
      assert_equal 1,quentin.accounts.count
 
    end  # should do
        
        
# #############################################################################
# ####  acts_as_account injected methods  #############
# #############################################################################
        
    should "raise exception if account is different" do
      target = members(:quentin_1)
         # now force account to invalid
      Account.set_current_account( 0 )
      
      assert_raise(::Milia::Control::InvalidAccountAccess,
         "InvalidAccountAccess if accounts dont match"){
         target.update_attributes( :first_name => "duck walk" )
      }
     end  # should do

    should 'raise exception if accounted tid not nil - destroy' do
      target = members(:quentin_1)
      assert_no_difference('Member.count') do
        assert_raise(::Milia::Control::InvalidAccountAccess) {
          target.account_id = 3
          target.destroy
        }
      end  # no diff do
    end  # should do
        
# #############################################################################
# ####  acts_as_universal injected methods  #############
# #############################################################################
    should 'always force universal account id to nil' do 
        # setup new world
      account = Account.create_new_account( 
            {name:   "Mangoland", account_id: 1}, 
            {email:  "billybob@bob.com"}, 
            {coupon: "FreeTrial"}
      )
      assert account.errors.empty?
      assert_nil  account.account_id
    end  # should do
 
 
    should 'raise exception if tid not nil - save' do
      account = accounts(:account_1)
      assert_raise(::Milia::Control::InvalidAccountAccess) {
        account.update_attributes( account_id: 3, name: 'wild blue2' )
      }

    end  # should do
 
    should 'raise exception if tid not nil - destroy' do
      account = accounts(:account_1)
      assert_no_difference('Account.count') do
        assert_raise(::Milia::Control::InvalidAccountAccess) {
          account.account_id = 3
          account.destroy
        }
      end  # no diff do
    end  # should do
 
# #############################################################################

  end  # context
 
# #############################################################################
end  # class test
