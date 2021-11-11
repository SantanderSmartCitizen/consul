class Admin::HeaderSlidesController < Admin::BaseController
  include Translatable
  include ImageAttributes
  include HeaderSlidesHelper

  has_filters %w[all homepage budgets polls debates proposals legislation_processes forums help], only: :index

  respond_to :html, :js

  load_and_authorize_resource

  def index
    @header_slides = HeaderSlide.send(@current_filter).page(params[:page])
  end

  def create
    @header_slide = HeaderSlide.new(header_slide_params)
    if @header_slide.save
      redirect_to admin_header_slides_path
    else
      render :new
    end
  end

  def update
    if @header_slide.update(header_slide_params)
      redirect_to admin_header_slides_path
    else
      render :edit
    end
  end

  def destroy
    @header_slide.destroy!
    redirect_to admin_header_slides_path
  end

  private

    def header_slide_params
      attributes = [:page, image_attributes: image_attributes]
      params.require(:header_slide).permit(*attributes, translation_params(HeaderSlide))
    end

    def resource
      @header_slide ||= HeaderSlide.find(params[:id])
    end
end
