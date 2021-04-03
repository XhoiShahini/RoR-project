class StaticController < ApplicationController
  def index
  end

  def about
  end

  def pricing
    redirect_to root_path, alert: t(".no_plans") unless Plan.without_free.exists?
  end

  def terms
  end

  def privacy
  end

  def phone_input_utils
    send_file "#{Rails.root}/node_modules/intl-tel-input/build/js/utils.js", type: "application/javascript", disposition: "inline"
  end
end
