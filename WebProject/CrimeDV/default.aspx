<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="CrimeDV._default" %>
<!DOCTYPE html> 
<html>
<head>
	<title>London crime data</title>
    <link rel="stylesheet" type="text/css" href="/styles/main.css" /> 
    <link rel="stylesheet" type="text/css" href="/styles/ol.css" /> 
    <script src="/scripts/d3.min.js" charset="utf-8"></script>
    <script src="/scripts/ol.js"></script>
    <meta name="description" content="London crime data visualiser. Includes points of interest and demographics." />
</head>
<body style="margin:0px 0px 0px 0px;font-family:Arial, Helvetica, sans-serif;">
<table style="width:100%;border-width:0px 0px 0px 0px;margin:0px 0px 0px 0px;padding:0px 0px 0px 0px;">
	<tr style="background-color:black;margin:5px 5px 5px 5px;color:white;">
		<td style="text-align:left">London Crime Data</td>
		<td style="text-align:right">Intro | Crime Data | About this project</td>
	</tr>
	<tr>
		<td colspan="2">
            <table style="width:100%;height:100%;border-width:0px 0px 0px 0px;margin:0px 0px 0px 0px;padding:0px 0px 0px 0px;">
                <tr>
                    <td style="width:400px;height:50%">Chart1</td>
                    <td rowspan="2" style="width:100%;height:100%"><div id="crimemap" class="map"></div></td>
                </tr>
                <tr>
                    <td style="width:400px;height:50%">Chart2</td>
                </tr>
            </table>
		</td>
	</tr>
</table>

<script>
    var layers = [];

    layers.push(new ol.layer.Tile({
        visible: true,
        preload: Infinity,
        source: new ol.source.BingMaps({
        key: 'Al2H4Jth3TkBcsuFvpl1FZmbBj4iTnd5P5BosDl6TzE87VmdXWnwDKEWJ-yEw2D8',
        imagerySet: 'Road'
        })
    }));

    var map = new ol.Map({
    layers: layers,
    // Improve user experience by loading tiles while dragging/zooming. Will make
    // zooming choppy on mobile or slow devices.
    loadTilesWhileInteracting: true,
    target: 'crimemap',
    view: new ol.View({
        center: [-6655.5402445057125, 6709968.258934638],
        zoom: 13
    })
    });

</script>

</body>
</html>
