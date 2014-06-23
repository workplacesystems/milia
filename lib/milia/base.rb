module Milia
  module Base

    def self.included(base)
      base.extend ClassMethods
    end

# #############################################################################
# #############################################################################
    module ClassMethods

# ------------------------------------------------------------------------
# acts_as_account -- makes a accounted model
# Forces all references to be limited to current_account rows
# ------------------------------------------------------------------------
      def acts_as_account()
        belongs_to  :account
        validates_presence_of :account_id

        default_scope lambda { where( "#{table_name}.account_id = ?", Thread.current[:account_id] ) }

      # ..........................callback enforcers............................
        before_validation(:on => :create) do |obj|   # force account_id to be correct for current_user
          obj.account_id = Thread.current[:account_id]
          true  #  ok to proceed
        end

      # ..........................callback enforcers............................
        before_save do |obj|   # force account_id to be correct for current_user
          # raise exception if updates attempted on wrong data
          raise ::Milia::Control::InvalidAccountAccess unless obj.account_id == Thread.current[:account_id]
          true  #  ok to proceed
        end

      # ..........................callback enforcers............................
        # no longer needed because before_save invoked prior to before_update
        #
#         before_update do |obj|   # force account_id to be correct for current_user
#           raise ::Milia::Control::InvalidAccountAccess unless obj.account_id == Thread.current[:account_id]
#           true  #  ok to proceed
#         end

      # ..........................callback enforcers............................
        before_destroy do |obj|   # force account_id to be correct for current_user
          raise ::Milia::Control::InvalidAccountAccess unless obj.account_id == Thread.current[:account_id]
          true  #  ok to proceed
        end

      end

# ------------------------------------------------------------------------
# acts_as_universal -- makes a univeral (non-accounted) model
# Forces all reference to the universal account (nil)
# ------------------------------------------------------------------------
      def acts_as_universal()
        belongs_to  :account

        default_scope { where( "#{table_name}.account_id IS NULL" ) }

      # ..........................callback enforcers............................
        before_save do |obj|   # force account_id to be universal
          raise ::Milia::Control::InvalidAccountAccess unless obj.account_id.nil?
          true  #  ok to proceed
        end

      # ..........................callback enforcers............................
#         before_update do |obj|   # force account_id to be universal
        # no longer needed because before_save invoked prior to before_update
        #
#           raise ::Milia::Control::InvalidAccountAccess unless obj.account_id.nil?
#           true  #  ok to proceed
#         end

      # ..........................callback enforcers............................
        before_destroy do |obj|   # force account_id to be universal
          raise ::Milia::Control::InvalidAccountAccess unless obj.account_id.nil?
          true  #  ok to proceed
        end

      end
      
# ------------------------------------------------------------------------
# acts_as_universal_and_determines_account_reference
# All the characteristics of acts_as_universal AND also does the magic
# of binding a user to a account
# ------------------------------------------------------------------------
      def acts_as_universal_and_determines_account()
        include ::Milia::InviteMember
        has_and_belongs_to_many :accounts

        acts_as_universal()

           # validate that a account exists prior to a user creation
        before_create do |new_user|
          if Thread.current[:account_id].blank? ||
             !Thread.current[:account_id].kind_of?(Integer) ||
             Thread.current[:account_id].zero?

            raise ::Milia::Control::InvalidAccountAccess,"no existing valid current account" 

          end
        end  # before create callback do
        
          # before create, tie user with current account
          # return true if ok to proceed; false if break callback chain
        after_create do |new_user|
          account = Account.find( Thread.current[:account_id] )
          unless account.users.include?(new_user)
            account.users << new_user  # add user to this account if not already there
          end

        end # before_create do
        
        before_destroy do |old_user|
          old_user.accounts.clear    # remove all accounts for this user
          true
        end # before_destroy do
        
      end  # acts_as

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
  def acts_as_universal_and_determines_account()
    has_and_belongs_to_many :users

    acts_as_universal()
    
    before_destroy do |old_account|
      old_account.users.clear  # remove all users from this account
      true
    end # before_destroy do
  end

# ------------------------------------------------------------------------
# current_account -- returns account obj for current account
  # return nil if no current account defined
# ------------------------------------------------------------------------
  def current_account()
    begin
      account = (
        Thread.current[:account_id].blank?  ?
        nil  :
        Account.find( Thread.current[:account_id] )
      )

      return account

    rescue ActiveRecord::RecordNotFound
      return nil
    end   
  end
    
# ------------------------------------------------------------------------
# current_account_id -- returns account_id for current account
# ------------------------------------------------------------------------
  def current_account_id()
    return Thread.current[:account_id]
  end
  
# ------------------------------------------------------------------------
# set_current_account -- model-level ability to set the current account
# NOTE: *USE WITH CAUTION* normally this should *NEVER* be done from
# the models ... it's only useful and safe WHEN performed at the start
# of a background job (DelayedJob#perform)
# ------------------------------------------------------------------------
  def set_current_account( account )
      # able to handle account obj or account_id
    case account
      when Account then account_id = account.id
      when Integer then account_id = account
      else
        raise ArgumentError, "invalid account object or id"
    end  # case
    
    old_id = ( Thread.current[:account_id].nil? ? '%' : Thread.current[:account_id] )
    Thread.current[:account_id] = account_id
    logger.debug("MILIA >>>>> [Account#change_account] new: #{account_id}\told:#{old_id}") unless logger.nil?

  end
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
 
# ------------------------------------------------------------------------
# where_restrict_account -- gens account restrictive where clause for each klass
# NOTE: subordinate join tables will not get the default scope by Rails
# theoretically, the default scope on the master table alone should be sufficient
# in restricting answers to the current_account alone .. HOWEVER, it doesn't feel
# right. adding an additional .where( where_restrict_accounts(klass1, klass2,...))
# for each of the subordinate models in the join seems like a nice safety issue.
# ------------------------------------------------------------------------
  def where_restrict_account(*args)
    args.map{|klass| "#{klass.table_name}.account_id = #{Thread.current[:account_id]}"}.join(" AND ")
  end
  
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

    end  # module ClassMethods
# #############################################################################
# #############################################################################
    
  end  # module Base
end  # module Milia
