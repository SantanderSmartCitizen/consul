class Admin::EventsController < Admin::BaseController
  include Translatable
  include ImageAttributes

  has_filters %w[all previous next], only: :index

  respond_to :html, :js

  load_and_authorize_resource

  def index
    @events = Event.send(@current_filter).page(params[:page])
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to admin_events_path
    else
      render :new
    end
  end

  def update
    if @event.update(event_params)
      redirect_to admin_events_path
    else
      render :edit
    end
  end

  def destroy
    @event.destroy!
    redirect_to admin_events_path
  end

  private

    def event_params
      attributes = [:start_time, :end_time,
                    image_attributes: image_attributes]
      params.require(:event).permit(*attributes, translation_params(Event))
    end

    def resource
      @event ||= Event.find(params[:id])
    end
end
