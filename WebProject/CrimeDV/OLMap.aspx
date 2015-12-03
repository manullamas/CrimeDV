<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OLMap.aspx.cs" Inherits="CrimeDV.OLMap" %>

<!doctype html>
<html lang="en">
  <head>
    <link rel="stylesheet" href="http://openlayers.org/en/v3.11.2/css/ol.css" type="text/css">
    <style>
      .map {
        height: 400px;
        width: 100%;
      }
    </style>
    <script src="http://openlayers.org/en/v3.11.2/build/ol.js" type="text/javascript"></script>
    <title>Crime Data Visualizer</title>
  </head>
  <body>
    <h2>Test app for Crime Data Visualizer</h2>
    <div id="map" class="map"></div>
    <script type="text/javascript">
        var map = new ol.Map({
        loadTilesWhileInteracting: true,
        target: 'map',
        layers: [
          new ol.layer.Tile({
              source: new ol.source.BingMaps({ key: 'Al2H4Jth3TkBcsuFvpl1FZmbBj4iTnd5P5BosDl6TzE87VmdXWnwDKEWJ-yEw2D8', imagerySet: 'Road', maxZoom: 19 })
          })
        ],
        view: new ol.View({
            center: ol.proj.fromLonLat([-0.076557, 51.508114]),
          zoom: 12
        })
      });
    </script>
  </body>
</html>