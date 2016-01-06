<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="mapd.aspx.cs" Inherits="CrimeDV.mapd" %>
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
                <table class="headerTable"><tr><td class="headerText">London Crime Data Visualiser</td>
                    <td class="headerNav">
                        <a href="/" class="navText"> Dashboard </a> | <a href="/mapn.aspx" class="navText">By Number</a> | <a href="/mapd.aspx" class="navText">By Density</a> | <a href="/mapb.aspx" class="navText">By Borrough</a></td></tr></table>
            </div>
        </div>
        <div class="body row" id="crimemap">
        </div>
        <div class="footer row">
            Site for Foundations of Data Science coursework. University of Southampton, 2016.
            <div class="leyendBox"><img src="/images/NCrimeLeyend.png" class="imgLeyend" /></div>
        </div>
        
    </form>
    <script>
        L.mapbox.accessToken = 'pk.eyJ1IjoibWliYWxsZSIsImEiOiJjaWowbzA5MzIwMDN2dWZtNTZmendnczB5In0.lS1yCvi3pTRFN6KPDvU31A';
        var map = L.map('crimemap', 'mapbox.street').setView([51.5119112, -0.10000], 11);
        var layer = L.mapbox.tileLayer('mapbox.light').addTo(map);
        var boroughsLayer = L.mapbox.featureLayer('/data/LONBoroughs.geo.json').addTo(map);
        var stationsLayer = L.mapbox.featureLayer('/data/Stations.geo.json').addTo(map);

        // Setup our svg layer that we can manipulate with d3
        var svg = d3.select(map.getPanes().markerPane)
          .append("svg");
        var g = svg.append("g").attr("class", "leaflet-zoom-hide");

        function project(ll) {
            // our data came from csv, make it Leaflet friendly
            var a = [+ll.Latitude, +ll.Longitude];
            // convert it to pixel coordinates
            var point = map.latLngToLayerPoint(L.latLng(ll.Latitude, ll.Longitude))
            return point;
        }

        d3.json("/data/StationsAll.json", function (err, data) {
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
                fprop = Math.sqrt(Math.sqrt(d.usage));
                if (fprop <= 30)
                    return 5;
                if (fprop >= 90)
                    return 40;
                else
                    return Math.round((((fprop-30) / 60 ) * 35) + 5)
            })
            .style({
                fill: function (d) {
                    sprop = Math.sqrt(d.Count.totals);
                    if (sprop <= 10)
                        return "#00FF00";
                    if (sprop >= 160)
                        return "#FF0000";
                    else {
                        bcolor = ((sprop - 10) / 150) * 255;
                        green = Math.round(255 - bcolor).toString(16).toUpperCase()
                        if (green.length == 1)
                            green = "0" + green;
                        red = Math.round(bcolor).toString(16).toUpperCase()
                        if (red.length == 1)
                            red = "0" + red;
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

