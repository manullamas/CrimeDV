   
    var map = L.map('map').setView([51.5119112,-0.10000], 12);
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
      var a = [+ll.lat, +ll.lng]; 
      // convert it to pixel coordinates
      var point = map.latLngToLayerPoint(L.latLng(ll))
      return point;
    }
  
    d3.json("london/crimesPerStations", function(err, data) {
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
/*       .attr("r", function(d) {
                     if(d.usage <= 100 )
                 return 1;
                                 if(d.usage > 1000 && d.usage <= 500000)
                                 return 5;
                                 if(d.usage > 500000 && d.usage < 1000000 )
                                 return 10;
                                 if(d.usage > 1000000 && d.usage < 3000000 )
                                 return 20;
                                 if(d.usage >= 3000000)
                                 return 30;}) */ 
 
       	.attr("r", function(d) { return 10;}) 
	  .style({fill : function(d) {
		/* 		 if(d.crimesNumb <= 400 )
                 return "#006600";
				 if(d.crimesNumb > 400 && d.crimesNumb <= 1000)
				 return "#ff9933";
				 if(d.crimesNumb > 1000 && d.crimesNumb <= 5000 )
				 return "#ff0000";
                                 if(d.crimesNumb > 5000 )
				 return "#000000";*/
		
    				 if(d.crimesNumb <= 0.01 )
                                 return "#006600";
                                 if(d.crimesNumb > 0.01 && d.crimesNumb <= 0.08)
                                 return "#ff9933";
                                 if(d.crimesNumb > 0.08 && d.crimesNumb <= 0.3 )
                                 return "#ff0000";
                                 if(d.crimesNumb > 0.3 )
                                 return "#000000";
 
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
    

