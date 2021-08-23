module MapLocationsHelper
  def map_location_available?(map_location)
    map_location.present? && map_location.available?
  end

  def map_location_latitude(map_location)
    map_location.present? && map_location.latitude.present? ? map_location.latitude : Setting["map.latitude"]
  end

  def map_location_longitude(map_location)
    map_location.present? && map_location.longitude.present? ? map_location.longitude : Setting["map.longitude"]
  end

  def map_location_zoom(map_location)
    map_location.present? && map_location.zoom.present? ? map_location.zoom : Setting["map.zoom"]
  end

  def map_location_input_id(prefix, attribute)
    "#{prefix}_map_location_attributes_#{attribute}"
  end

  def map_location_remove_marker_link_id(map_location)
    "remove-marker-link-#{dom_id(map_location)}"
  end

  def render_map(map_location, parent_class, editable, remove_marker_label, investments_coordinates = nil, find_proposals_by_district = nil)
    map_location = MapLocation.new if map_location.nil?
    map = content_tag :div, "",
                      id: dom_id(map_location),
                      class: "map_location map",
                      data: prepare_map_settings(map_location, editable, parent_class, investments_coordinates, find_proposals_by_district)
    map += map_info_pane
    map += map_location_remove_marker(map_location, remove_marker_label) if editable
    map
  end

  def map_info_pane
    content_tag :small, "",
                id: "info-pane",
                style: "position: inherit; color: rgb(39, 90, 118); font-weight: bold; float: right;min-height: 25px;";
  end

  def map_location_remove_marker(map_location, text)
    content_tag :div, class: "margin-bottom" do
      content_tag :a,
                  id: map_location_remove_marker_link_id(map_location),
                  href: "#",
                  class: "js-location-map-remove-marker location-map-remove-marker" do
        text
      end
    end
  end

  private

    def prepare_map_settings(map_location, editable, parent_class, investments_coordinates = nil, find_proposals_by_district = nil)
      options = {
        map: "",
        map_center_latitude: map_location_latitude(map_location),
        map_center_longitude: map_location_longitude(map_location),
        map_zoom: map_location_zoom(map_location),
        map_tiles_provider: Rails.application.secrets.map_tiles_provider,
        map_tiles_provider_attribution: Rails.application.secrets.map_tiles_provider_attribution,
        marker_editable: editable,
        marker_remove_selector: "##{map_location_remove_marker_link_id(map_location)}",
        latitude_input_selector: "##{map_location_input_id(parent_class, "latitude")}",
        longitude_input_selector: "##{map_location_input_id(parent_class, "longitude")}",
        zoom_input_selector: "##{map_location_input_id(parent_class, "zoom")}",
        marker_investments_coordinates: investments_coordinates,
        map_arcgis_feature_layer_url: Setting["map.arcgis.feature_layer_url"],
        map_arcgis_district_code_field: Setting["map.arcgis.district_code_field"],
        map_geozones: Geozone.all.index_by(&:external_code),
        find_proposals_by_district: find_proposals_by_district
      }
      options[:marker_latitude] = map_location.latitude if map_location.latitude.present?
      options[:marker_longitude] = map_location.longitude if map_location.longitude.present?
      options
    end
end
