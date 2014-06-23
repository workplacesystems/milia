require 'test_helper'
 
# #############################################################################
# Note: this tests not only the methods in models/user.rb but
# also all of the milia-injected methods from base.rb for
# acts_as_universal_and_determines_account
# #############################################################################
 
class UserTest < ActiveSupport::TestCase

  context "a user" do
    
    setup do
      Account.set_current_account( accounts( :account_1 ).id )
      @user = users(:quentin)
    end

    should have_one( :member )
    should have_many( :accounted_members )
    should have_and_belong_to_many( :accounts )
    should_not allow_value("wild blue").for(:email)
    
    should have_db_column(:account_id)
    should have_db_column(:skip_confirm_change_password).with_options(default: false)

    should have_db_index(:email)
    should have_db_index(:confirmation_token)
    should have_db_index(:reset_password_token)
    
    should "define the current account" do
      assert  Thread.current[:account_id]
    end

    should 'have password' do
      assert !@user.has_no_password?
    end   # should do

    should 'not have password' do
      assert  User.new(email: "billybob@bob.com").has_no_password?
    end   # should do

    should 'attempt set password' do
      assert users(:jermaine).attempt_set_password(
        password: 'wild_blue',
        password_confirmation: 'wild_blue'
      )
    end   # should do

    should 'check or set password - missing' do
      user = User.new(email: "billybob@bob.com")
      assert user.has_no_password?
      user.check_or_set_password
      assert !user.has_no_password?
      assert !user.skip_confirm_change_password?
    end   # should do

    should 'check or set password - present' do
      user = User.new(
        email: "billybob@bob.com",
        password: 'limesublime',
        password_confirmation: 'limesublime'
      )
      assert !user.has_no_password?
      user.check_or_set_password
      assert user.skip_confirm_change_password?
    end   # should do

    should 'save and invite member - error no email' do
      user = User.new(password: "wildblue")
      assert_nil user.save_and_invite_member
      assert !user.errors.empty?
    end   # should do

    should 'save and invite member - error duplicate email' do
      user = User.new(email: "jermaine@example.com")
      assert_nil user.save_and_invite_member
      assert !user.errors.empty?
    end   # should do

    should 'save and invite member - success' do
      user = User.new(email: "limesublime@example.com")
      assert user.save_and_invite_member
      assert user.errors.empty?
    end   # should do

# #############################################################################
# #############################################################################


    should 'NOT create new user when invalid current account - string' do
              # force the current_account to be unexpected object
      Thread.current[:account_id] = 'peanut clusters'
      
      assert_no_difference("User.count") do
        assert_raise(::Milia::Control::InvalidAccountAccess,
          "no existing valid current account")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference
 
    end  # should do

    should 'NOT create new user when invalid current account - nil' do
              # force the current_account to be nil
      Thread.current[:account_id] = nil
      
      assert_no_difference("User.count") do
        assert_raise(::Milia::Control::InvalidAccountAccess,
          "no existing valid current account")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference
 
    end  # should do

    should 'NOT create new user when invalid current account - zero' do
              # force the current_account to be 0
      Thread.current[:account_id] = 0
      
      assert_no_difference("User.count") do
        assert_raise(::Milia::Control::InvalidAccountAccess,
          "no existing valid current account")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference
 
    end  # should do

# this validates both the before_create and after_create for users
    should 'create new user when valid current account' do
      account = accounts(:account_1)
      assert_equal 1,account.users.count
      
      assert_difference("User.count") do
        assert_nothing_raised(::Milia::Control::InvalidAccountAccess,
          "no existing valid current account")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference

      account.reload
      assert_equal 2,account.users.count
 
    end  # should do


    should 'destroy a user and clear its accounts habtm' do
      account = accounts(:account_2)
      Account.set_current_account( account )
      quentin = users(:quentin)
      assert_equal 3,account.users.count
      quentin.destroy
      account.reload
      assert_equal 2,account.users.count
    end # should do



    # ok to create user, member
#     @user   = User.new( user_params )
#     if @user.save_and_invite_member() && @user.create_member( member_params )

  
  end   # context user

end  # class
