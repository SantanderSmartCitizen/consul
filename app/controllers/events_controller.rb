class EventsController < ApplicationController
  
  include Translatable

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def index
  	start_date = params.fetch(:start_date, Date.today).to_date
  	date_range = start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week
	@events = Event.where(start_time: date_range).or(Event.where(end_time: date_range))
  end

  def show
  end

  private
    def resource_model
	  Event
    end
end
