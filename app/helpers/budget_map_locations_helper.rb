module BudgetMapLocationsHelper
  def budget_map_location_available?(budget_map_location)
    budget_map_location.present? && budget_map_location.available?
  end

  def budget_map_location_latitude(budget_map_location)
    budget_map_location.present? && budget_map_location.latitude.present? ? budget_map_location.latitude : Setting["budget_map.latitude"]
  end

  def budget_map_location_longitude(budget_map_location)
    budget_map_location.present? && budget_map_location.longitude.present? ? budget_map_location.longitude : Setting["budget_map.longitude"]
  end

  def budget_map_location_zoom(budget_map_location)
    budget_map_location.present? && budget_map_location.zoom.present? ? budget_map_location.zoom : Setting["budget_map.zoom"]
  end

  def budget_map_location_input_id(prefix, attribute)
    "#{prefix}_budget_map_location_attributes_#{attribute}"
  end

  def budget_map_location_remove_marker_link_id(budget_map_location)
    "remove-marker-link-#{dom_id(budget_map_location)}"
  end

  def render_budget_map(budget_map_location, parent_class, editable, remove_marker_label, investments_coordinates = nil)
    budget_map_location = MapLocation.new if budget_map_location.nil?
    map = content_tag :div, "",
                      id: dom_id(budget_map_location),
                      class: "map_location map",
                      data: prepare_budget_map_settings(budget_map_location, editable, parent_class, investments_coordinates)
    map += budget_map_info_pane
    map += budget_map_location_remove_marker(budget_map_location, remove_marker_label) if editable
    map
  end

  def budget_map_info_pane
    content_tag :small, "",
                class: "map-info-pane";
  end

  def budget_map_location_remove_marker(budget_map_location, text)
    content_tag :div, class: "margin-bottom" do
      content_tag :a,
                  id: budget_map_location_remove_marker_link_id(budget_map_location),
                  href: "#",
                  class: "js-location-map-remove-marker location-map-remove-marker" do
        text
      end
    end
  end

  private

    def prepare_budget_map_settings(budget_map_location, editable, parent_class, investments_coordinates = nil)
      options = {
        map: "",
        map_center_latitude: budget_map_location_latitude(budget_map_location),
        map_center_longitude: budget_map_location_longitude(budget_map_location),
        map_zoom: budget_map_location_zoom(budget_map_location),
        map_tiles_provider: Rails.application.secrets.map_tiles_provider,
        map_tiles_provider_attribution: Rails.application.secrets.map_tiles_provider_attribution,
        marker_editable: editable,
        marker_remove_selector: "##{budget_map_location_remove_marker_link_id(budget_map_location)}",
        latitude_input_selector: "##{budget_map_location_input_id(parent_class, "latitude")}",
        longitude_input_selector: "##{budget_map_location_input_id(parent_class, "longitude")}",
        zoom_input_selector: "##{budget_map_location_input_id(parent_class, "zoom")}",
        marker_investments_coordinates: investments_coordinates,
        map_arcgis_feature_layer_url: Setting["budget_map.arcgis.feature_layer_url"],
        map_arcgis_district_code_field: Setting["budget_map.arcgis.district_code_field"],
        map_geozones: BudgetGeozone.all.index_by(&:external_code),
        find_proposals_by_district: false
      }
      options[:marker_latitude] = budget_map_location.latitude if budget_map_location.latitude.present?
      options[:marker_longitude] = budget_map_location.longitude if budget_map_location.longitude.present?
      options
    end
end
