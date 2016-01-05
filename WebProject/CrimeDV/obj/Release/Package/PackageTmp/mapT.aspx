<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="mapT.aspx.cs" Inherits="CrimeDV.mapT" %>

<!DOCTYPE html>
<head>
    <title>London crime data</title>
    <meta charset="utf-8">
    <script src='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.js'></script>
    <link href='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.css' rel='stylesheet' />
    <link href="/styles/nv.d3.css" rel="stylesheet" type="text/css">
    <script src="/scripts/nv.d3.js"></script>
	<script src="/scripts/lineBarsChart.js"></script>
	<script src="/scripts/scriptStackedChart.js"></script>
  <style>
   body, html { height: 100%; }
    #map { 
      width: 100%;
      height: 100%;
    }
	
	svg {
            display: block;
        }
        
  </style>
</head>

<body style="margin:0px 0px 0px 0px;font-family:Arial, Helvetica, sans-serif;">
<table  style="width:100%;height:100%">
<tr style="background-color:black;margin:5px 5px 5px 5px;color:white;">
		<td style="text-align:left">London Crime Data</td>
		<td style="text-align:right">Intro | Crime Data | About this project</td>
	</tr>
                <tr>
                    <td style="width:600px;height:50%"><svg id="chart1"> </svg></td>
                    <td  rowspan="2" style="height:100%"><div id="map"></div></td>
                </tr>
                <tr>
                    <td style="width:600px;height:50%"><svg id="chart2"> </svg></td>
                </tr>
</table>
  
  <script>
   
    var map = L.map('map').setView([51.5119112,-0.10000], 10);
        mapLink = 
            '<a href="http://openstreetmap.org">OpenStreetMap</a>';
        L.tileLayer(
            'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; ' + mapLink + ' Contributors',
            maxZoom: 18,
            }).addTo(map);
			
    
    // Setup our svg layer that we can manipulate with d3
    var svg = d3.select(map.getPanes().overlayPane)
      .append("svg");
    var g = svg.append("g").attr("class", "leaflet-zoom-hide");
    
    function project(ll) {
      // our data came from csv, make it Leaflet friendly
      var a = [+ll.lat, +ll.lon]; 
      // convert it to pixel coordinates
      var point = map.latLngToLayerPoint(L.latLng(ll))
      return point;
    }
  
    d3.json("/data/dataStations.json", function(err, data) {
      var dots = g.selectAll("circle.dot").data(data)
      
      dots.enter().append("circle").classed("dot", true)
      .attr("r", 1)
      .style({
        fill: "#0082a3",
        "fill-opacity": 0.6,
        stroke: "#004d60",
        "stroke-width": 1
      })
      .transition().duration(1000)
      .attr("r", function(d) {
	             if(d.flow <= 100 )
                 return 5;
				 if(d.flow > 100 && d.flow <= 500)
				 return 10;
				 if(d.flow > 500 && d.flow < 1000 )
				 return 20;
				 if(d.flow >= 1000)
				 return 40;})
	  .style({fill : function(d) {
				 if(d.crime <= 10 )
                 return "#006600";
				 if(d.crime > 10 && d.crime <= 100)
				 return "#ff9933";
				 if(d.crime > 100 && d.crime < 1000 )
				 return "#ff0000";
                   } } )
      
      
      function render() {

        var bounds = map.getBounds();
        var topLeft = map.latLngToLayerPoint(bounds.getNorthWest())
        var bottomRight = map.latLngToLayerPoint(bounds.getSouthEast())
        svg.style("width", map.getSize().x + "px")
          .style("height", map.getSize().y + "px")
          .style("left", topLeft.x + "px")
          .style("top", topLeft.y + "px");
        g.attr("transform", "translate(" + -topLeft.x + "," + -topLeft.y + ")");

        // We reproject our data with the updated projection from leaflet
        g.selectAll("circle.dot")
        .attr({
          cx: function(d) { return project(d).x},
          cy: function(d) { return project(d).y},
        })

      }

      // re-render our visualization whenever the view changes
      map.on("viewreset", function() {
        render()
      })
      map.on("move", function() {
        render()
      })

      // render our initial visualization
      render()
    })
    
  </script>
</body>
