module HeaderSlidesHelper

  def header_slide_pages_select_options
    HeaderSlide::PAGES.map { |page| [t("admin.header_slides.header_slide.pages.#{page}"), page] }
  end

 end