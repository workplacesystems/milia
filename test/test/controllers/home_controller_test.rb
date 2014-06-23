require 'ctlr_test_helper'

class HomeControllerTest < ActionController::TestCase
    
  context 'home ctlr' do
    setup do
      Account.set_current_account( accounts( :account_1 ).id )
    end

  should "get index" do
    get :index
    assert_response :success
  end

  should "get show with login" do
    sign_in( users( :quentin ) )
    get :show
    assert_response :success
    sign_out( users( :quentin ) )
  end  # should do

  should 'not get show without login' do
    assert_raise(ArgumentError, 'uncaught throw :warden'){
      get :show
    }
    assert_response :success
  end  # should do

  should 'reset account' do
    assert Account.current_account_id
    @controller.__milia_reset_account!   # invoke the private method
    assert_nil Account.current_account_id

  end  # should do

  should 'change account' do
    assert_equal 1,Account.current_account_id
    @controller.__milia_change_account!(2)   # invoke the private method
    assert_equal 2,Account.current_account_id
  end  # should do

  should 'trace accounting' do
    ::Milia.trace_on = true
    @controller.trace_accounting( "wild blue" )
    ::Milia.trace_on = false
    @controller.trace_accounting( "duck walk" )
  end  # should do

  should 'initiate account' do
    @controller.initiate_account( accounts(:account_2) )
    assert_equal 2,Account.current_account_id
  end  # should do

  should 'redirect back' do
       # alter the code to invoke redirect_back
    @controller.class.module_eval(
      %q{
        def index()
          redirect_back
        end
      }
    )

       # now test it
    get :index
    assert_response :redirect
    assert_redirected_to  root_url()

  end  # should do

  should 'prep signup view' do
    assert_nil  @controller.instance_eval( "@account" )
    @controller.prep_signup_view( 
        { name: 'Mangoland' }, 
        {email: 'billybob@bob.com', password: 'monkeymocha', password_confirmation: 'monkeymocha'} 
    )
    assert_equal 'Mangoland', @controller.instance_eval( "@account" ).name
  end  # should do

  should 'handle max_accounts exception' do
       # alter the code to invoke redirect_back
    @controller.class.module_eval(
      %q{
        def index()
          max_accounts
        end
      }
    )

       # now test it
    get :index, { user: { email: 'billybob@bob.com' }, account: {name: 'Mangoland'} }
    assert_response :redirect
    assert_redirected_to  root_url()

  end  # should do


  should 'set current account - user not signed in' do
    assert  @controller.set_current_account( 2 )
    assert_nil  Account.current_account_id
  end  # should do


  should 'set current account - user signed in; tid not nil; valid for user' do
    sign_in( users( :quentin ) )
    assert  @controller.set_current_account( 2 )
    assert_equal  2,Account.current_account_id
  end  # should do

  should 'set current account - user signed in; tid not nil; invalid for user' do
    sign_in( users( :quentin ) )
    assert_raise(Milia::Control::InvalidAccountAccess){
      @controller.set_current_account( 3 )
    }
    assert_equal  1,Account.current_account_id   # should be unchanged
  end  # should do


  should 'authenticate account - 1' do

    @controller.set_current_account( )
    sign_in( users( :quentin ) )
    @controller.authenticate_account!
    assert_response :success
    assert_equal  1,Account.current_account_id

  end  # should do



  end  # context

end  # end class test
