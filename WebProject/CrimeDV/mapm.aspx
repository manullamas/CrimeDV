<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="mapm.aspx.cs" Inherits="CrimeDV.mapm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>London Crime Data Visualiser</title>

    <link href='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.css' rel='stylesheet' />
    <link rel="stylesheet" type="text/css" href="/styles/main.css" />
    <link rel="stylesheet" type="text/css" href="/styles/ol.css" />
    <script src="/scripts/d3.min.js" charset="utf-8"></script>
    <script src="/scripts/ol.js"></script>
    <script src='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.js'></script>
    <meta name="description" content="London crime data visualiser. Includes points of interest and demographics." />
</head>
<body>
    <form id="form1" runat="server">
        <div class="header row">
            <div class="headertitle">
                London Crime Data Visualiser
            </div>
            <div class="headernav">
                About this Project | Filters
            </div>
        </div>
        <div class="body row" id="crimemap">
        </div>
        <div class="footer row">
            Site for Foundations of Data Science coursework. University of Southampton, 2016.
        </div>
    </form>
    <script>

        var map = L.map('crimemap').setView([51.5119112, -0.10000], 13);
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

        d3.json("/data/LONstations.json", function (err, data) {
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
            .attr("r", function (d) {
                fprop = Math.sqrt(Math.sqrt(d.flow));
                if (fprop <= 30)
                    return 5;
                if (d.flow >= 90)
                    return 40;
                else
                    return Math.round((((fprop-30) / 60 ) * 35) + 5)
            })
            .style({
                fill: function (d) {
                    if (d.crime <= 50)
                        return "#00FF00";
                    if (d.crime >= 650)
                        return "#FF0000";
                    else {
                        bcolor = ((d.crime - 50) / 600) * 255;
                        red = Math.round(255 - bcolor).toString(16).toUpperCase()
                        green = Math.round(bcolor).toString(16).toUpperCase()
                        return "#" + red + green + "33"
                    }
                }
            })


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
                    cx: function (d) { return project(d).x },
                    cy: function (d) { return project(d).y },
                })

            }

            // re-render our visualization whenever the view changes
            map.on("viewreset", function () {
                render()
            })
            map.on("move", function () {
                render()
            })

            // render our initial visualization
            render()
        })

    </script>
</body>
</html>
