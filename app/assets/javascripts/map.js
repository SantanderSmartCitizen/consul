(function() {
  "use strict";
  App.Map = {
    initialize: function() {
      $("*[data-map]").each(function() {
        App.Map.initializeMap(this);
      });
      $(".js-toggle-map").on({
        click: function() {
          App.Map.toggleMap();
        }
      });
    },
    initializeMap: function(element) {
      var addMarkerInvestments, clearFormfields, createMarker, editable, getPopupContent, latitudeInputSelector, longitudeInputSelector, map, mapAttribution, mapCenterLatLng, mapCenterLatitude, mapCenterLongitude, mapTilesProvider, marker, markerIcon, markerLatitude, markerLongitude, moveOrPlaceMarker, openMarkerPopup, removeMarker, removeMarkerSelector, updateFormfields, zoom, zoomInputSelector, mapArcgisFeatureLayerUrl, mapArcgisDistrictCodeField, mapGeozones, findProposalsByDistrict;
      App.Map.cleanInvestmentCoordinates(element);
      mapCenterLatitude = $(element).data("map-center-latitude");
      mapCenterLongitude = $(element).data("map-center-longitude");
      markerLatitude = $(element).data("marker-latitude");
      markerLongitude = $(element).data("marker-longitude");
      zoom = $(element).data("map-zoom");
      mapTilesProvider = $(element).data("map-tiles-provider");
      mapAttribution = $(element).data("map-tiles-provider-attribution");
      latitudeInputSelector = $(element).data("latitude-input-selector");
      longitudeInputSelector = $(element).data("longitude-input-selector");
      zoomInputSelector = $(element).data("zoom-input-selector");
      removeMarkerSelector = $(element).data("marker-remove-selector");
      addMarkerInvestments = $(element).data("marker-investments-coordinates");
      editable = $(element).data("marker-editable");
      mapArcgisFeatureLayerUrl = $(element).data("map-arcgis-feature-layer-url");
      mapArcgisDistrictCodeField = $(element).data("map-arcgis-district-code-field");
      mapGeozones = $(element).data("map-geozones");
      findProposalsByDistrict = $(element).data("find-proposals-by-district");

      marker = null;
      markerIcon = L.divIcon({
        className: "map-marker",
        iconSize: [30, 30],
        iconAnchor: [15, 40],
        html: '<div class="map-icon"></div>'
      });
      createMarker = function(latitude, longitude) {
        var markerLatLng;
        markerLatLng = new L.LatLng(latitude, longitude);
        marker = L.marker(markerLatLng, {
          icon: markerIcon,
          draggable: editable
        });
        if (editable) {
          marker.on("dragend", updateFormfields);
        }
        marker.addTo(map);
        return marker;
      };
      removeMarker = function(e) {
        e.preventDefault();
        if (marker) {
          map.removeLayer(marker);
          marker = null;
        }
        clearFormfields();
      };
      moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = createMarker(e.latlng.lat, e.latlng.lng);
        }
        updateFormfields();
      };
      updateFormfields = function() {
        $(latitudeInputSelector).val(marker.getLatLng().lat);
        $(longitudeInputSelector).val(marker.getLatLng().lng);
        $(zoomInputSelector).val(map.getZoom());
      };
      clearFormfields = function() {
        $(latitudeInputSelector).val("");
        $(longitudeInputSelector).val("");
        $(zoomInputSelector).val("");
      };
      openMarkerPopup = function(e) {
        marker = e.target;
        $.ajax("/investments/" + marker.options.id + "/json_data", {
          type: "GET",
          dataType: "json",
          success: function(data) {
            e.target.bindPopup(getPopupContent(data)).openPopup();
          }
        });
      };
      getPopupContent = function(data) {
        return "<a href='/presupuestos/" + data.budget_id + "/propuestas/" + data.investment_id + "'>" + data.investment_title + "</a>";
      };
      mapCenterLatLng = new L.LatLng(mapCenterLatitude, mapCenterLongitude);
      map = L.map(element.id).setView(mapCenterLatLng, zoom);

      L.esri.basemapLayer('Gray').addTo(map);
      L.esri.basemapLayer('GrayLabels').addTo(map);

      var distritos = L.esri.featureLayer({
        url: mapArcgisFeatureLayerUrl,
        simplifyFactor: 0.35,
        precision: 5,
        style: {
          color: 'rgb(38, 89, 118)',
          weight: 1
        }
      }).addTo(map);
      
      var oldId;

      distritos.on('mouseout', function (e) {
        /*document.getElementById('info-pane').innerHTML = '';*/
        document.querySelectorAll(".map-info-pane").forEach(function (element, index, array) {
          element.innerHTML = '';
        });
        distritos.resetFeatureStyle(oldId);
      });

      distritos.on('mouseover', function (e) {
        oldId = e.layer.feature.id;
        var geozoneCode = e.layer.feature.properties[mapArcgisDistrictCodeField];
        /*document.getElementById('info-pane').innerHTML = mapGeozones[geozoneCode]['name'];*/
        document.querySelectorAll(".map-info-pane").forEach(function (element, index, array) {
          element.innerHTML = mapGeozones[geozoneCode]['name'];
        });

        distritos.setFeatureStyle(e.layer.feature.id, {
          color: 'rgb(38, 89, 118)',
          weight: 3,
          opacity: 1
        });
      });

      if (findProposalsByDistrict) {
        distritos.on('click', function (e) {
          var geozoneCode = e.layer.feature.properties[mapArcgisDistrictCodeField];
          window.location.href = '/proposals?search='+ mapGeozones[geozoneCode]['name'];
        });
      }
      
      if (markerLatitude && markerLongitude && !addMarkerInvestments) {
        marker = createMarker(markerLatitude, markerLongitude);
      }
      if (editable) {
        $(removeMarkerSelector).on("click", removeMarker);
        map.on("zoomend", updateFormfields);
        map.on("click", moveOrPlaceMarker);
      }
      if (addMarkerInvestments) {
        addMarkerInvestments.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            marker = createMarker(coordinates.lat, coordinates.long);
            marker.options.id = coordinates.investment_id;
            marker.on("click", openMarkerPopup);
          }
        });
      }
    },
    toggleMap: function() {
      $(".map").toggle();
      $(".js-location-map-remove-marker").toggle();
    },
    cleanInvestmentCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-investments-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-investments-coordinates", clean_markers);
      }
    },
    validCoordinates: function(coordinates) {
      return App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long);
    },
    isNumeric: function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
  };
}).call(this);
