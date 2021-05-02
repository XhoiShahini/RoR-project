module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include SetCurrentRequestDetails

    identified_by :current_user, :current_participant, :current_account
    delegate :session, to: :request

    def connect
      self.current_user = find_verified_user
      set_request_details
      self.current_account = Current.account

      logger.add_tags "ActionCable", "#{current_user ? "User #{current_user.id}" : "Participant #{current_participant.id}"}", "Account #{current_account.id}"
    end

    protected

    def find_verified_user
      if (current_user = env["warden"].user)
        current_user
      elsif (session[:participant_id].present? && 
             current_participant = Participant.find(session[:participant_id]))
        self.current_participant = current_participant
        nil
      else
        reject_unauthorized_connection
      end
    end

    def user_signed_in?
      !!current_user
    end

    # Used by set_request_details
    def set_current_tenant(account)
      ActsAsTenant.current_tenant = account
    end
  end
end
