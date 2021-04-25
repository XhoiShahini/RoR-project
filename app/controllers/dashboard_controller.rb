class DashboardController < ApplicationController
  def show
    if current_user
      @meetings = current_user.meetings
    elsif current_participant
      redirect_to current_participant.meeting
    else
      authenticate_user!
    end
  end
end
