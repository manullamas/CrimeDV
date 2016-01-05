queue()
    .defer(d3.json, "london/crimesPerAll")
  //  .defer(d3.json, "london/crimesPerLsoa")
  //  .defer(d3.json, "london/crimesPerType")
    .defer(d3.json, "static/geojson/don.json")
    .await(makeGraphs);

function makeGraphs(error, crimesPerAllJson, statesJson) {
	
	//Clean projectsJson data
	var londonCrimesPerAll = crimesPerAllJson;
    //    var londonCrimesPerLsoa = crimesPerLsoaJson;
     //   var londonCrimesPerType = crimesPerTypeJson;

	var dateFormat = d3.time.format("%Y-%m");
	londonCrimesPerAll.forEach(function(d) {
		d["_id"]["M"] = dateFormat.parse(d["_id"]["M"]);
	});

	//Create a Crossfilter instance
	var ndx1 = crossfilter(londonCrimesPerAll);
//	var ndx2 = crossfilter(londonCrimesPerLsoa);
//	var ndx3 = crossfilter(londonCrimesPerType);

	//Define Dimensions
	var dateDim = ndx1.dimension(function(d) { return d["_id"]["M"]; });
	var crimeTypeDim = ndx1.dimension(function(d) { return d["_id"]["C"]; });
	var LSOADim = ndx1.dimension(function(d) { return d["_id"]["L"]; });
        var ReportedByDim = ndx1.dimension(function(d) { return d["_id"]["R"]; });

//	var stationDim  = ndx.dimension(function(d) { return d["station"]; });


	//Calculate metrics
	var numCrimesByDate = dateDim.group().reduceSum(function(d) { return d["n"]; }); 
	var numCrimesByCrimeType = crimeTypeDim.group().reduceSum(function(d) { return d["n"]; });
	var numCrimesByLSOA = LSOADim.group().reduceSum(function(d) { return d["n"]; });
	var numCrimesByReportedBy = ReportedByDim.group().reduceSum(function(d) { return d["n"]; });

//	var totalCrimesByLSOA = LSOADim.group().reduceSum(function(d) {
//		return d["total_donations"];
//	});

//	var all = ndx1.groupAll();
	var totalCrimes = ndx1.groupAll().reduceSum(function(d) {return d["n"];});

	var max_LSOA = numCrimesByLSOA.top(1)[0].value;

	//Define values (to be used in charts)
	var minDate = dateDim.bottom(1)[0]["_id"]["M"];
	var maxDate = dateDim.top(1)[0]["_id"]["M"];

        var numberFormat = d3.format(".2f");

    //Charts
	var timeChart = dc.barChart("#time-chart");
	var crimeTypeChart = dc.rowChart("#resource-type-row-chart");
	var reportedByChart = dc.rowChart("#poverty-level-row-chart");
	var usChart = dc.geoChoroplethChart("#us-chart");
 //	var numberCrimesND = dc.numberDisplay("#number-projects-nd");
	var totalCrimesND = dc.numberDisplay("#total-donations-nd");

/*	numberCrimesND
	   .formatNumber(d3.format("d"))
	   .valueAccessor(function(d){return d; })
	   .group(all);
*/

	totalCrimesND
	   .formatNumber(d3.format("d"))
	   .valueAccessor(function(d){return d; })
	   .group(totalCrimes)
	   .formatNumber(d3.format(".3s"));


        timeChart
	   .width(600)
	   .height(150)
	   .margins({top: 10, right: 30, bottom: 30, left: 70})
	   .dimension(dateDim)
	   .group(numCrimesByDate)
           .transitionDuration(500)
	   .x(d3.time.scale().domain([minDate, maxDate]))
	   .elasticY(true)
	   .yAxis().ticks(4);

	crimeTypeChart
           .width(300)
           .height(350)
           .dimension(crimeTypeDim)
           .group(numCrimesByCrimeType)
           .elasticX(true)
           .xAxis().ticks(3);

	reportedByChart
	   .width(300)
	   .height(350)
           .dimension(ReportedByDim)
           .group(numCrimesByReportedBy)
           .elasticX(true)
           .xAxis().ticks(3);


//////////////////////////Map projection position /////////////////////////////////
var width  = 300;
var height = 400;

// create a first guess for the projection
      var center = d3.geo.centroid(statesJson)
      var scale  = 150;
      var offset = [300 + width/2, height/2];
      var projection = d3.geo.mercator().scale(scale).center(center)
          .translate(offset);
      // create the path
      var path = d3.geo.path().projection(projection);
      // using the path determine the bounds of the current map and use 
      // these to determine better values for the scale and translation
      var bounds  = path.bounds(statesJson);
      var hscale  = scale*width  / (bounds[1][0] - bounds[0][0]);
      var vscale  = scale*height / (bounds[1][1] - bounds[0][1]);
     
 var scale   = (hscale < vscale) ? hscale : vscale;
     // var offset  = [width + 50 - (bounds[0][0] + bounds[1][0])/2, height - (bounds[0][1] + bounds[1][1])/2];
      // new projection
      projection = d3.geo.mercator().center(center).scale(scale*1.5).translate(offset);
      path = path.projection(projection);
//////////////////////////////////////////////////////////////////////////////////

      usChart.width(1000)
	     .height(400)
	     .dimension(LSOADim)
	     .group(numCrimesByLSOA)
  	     .colors(["#E2F2FF", "#C4E4FF", "#9ED2FF", "#81C5FF", "#6BBAFF", "#51AEFF", "#36A2FF", "#1E96FF", "#0089FF", "#0061B5"])
	     .colorDomain([0, max_LSOA])
	     .overlayGeoJson(statesJson["features"], "state", function (d) {
			return d.properties.LAD13NM;
	     })
	     .projection(projection)
	     .title(function (p) {
		return "LAD : " + p["key"]
				+ "\n"
				+ "Number Crimes: " + p["value"];
	     })

    dc.renderAll();

};
