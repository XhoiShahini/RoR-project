module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do |base|
    if base < ActionController::Base
      set_current_tenant_through_filter
      before_action :set_request_details
    end
  end

  def set_request_details
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
    Current.user = current_user

    set_current_participant
    # Account may already be set by the AccountMiddleware
    Current.account ||= account_from_domain || account_from_subdomain || account_from_session || fallback_account

    set_current_tenant(Current.account)
  end

  def set_current_participant
    if session[:participant_id].present?
      Current.participant = Participant.find(session[:participant_id]) rescue nil
      Current.account = Current.participant.account if Current.participant
    end
  end

  def account_from_domain
    return unless Jumpstart::Multitenancy.domain?
    Account.find_by(domain: request.domain)
  end

  def account_from_subdomain
    return unless Jumpstart::Multitenancy.subdomain? && request.subdomains.size > 0
    Account.find_by(subdomain: request.subdomains.first)
  end

  def account_from_session
    return unless Jumpstart::Multitenancy.session? && user_signed_in?
    current_user.accounts.find_by(id: session[:account_id])
  end

  def fallback_account
    return unless user_signed_in?
    current_user.accounts.order(created_at: :asc).first || current_user.create_default_account
  end
end
