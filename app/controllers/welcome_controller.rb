class WelcomeController < ApplicationController

  def index
      @count_prescriptions_today = Prescription.where("date_received >= :today", { today: Date.today.beginning_of_day }).count
      @date = Date.today.beginning_of_day
  end
end
