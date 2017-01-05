function areaPerformanceMatrixPlot(){
  // Creates area performance comparison plots using a tiled layout, with
  // outter tile color-encoding S.D. of performance, and center tile
  // color-encoding mean of performance.


  // Define size of squares to determine plot size and boundaries

  var r = 30,   // width of each tile/rectangle
      border = 4+Math.floor(r/10),  // border length between each tiles
      cols = areaPerformances.signalLabels.length,    // number of columns
      rows = areaPerformances.areaLabels.length;     // number of rows

  var colW = 80;     // colorbar svg element width
  var plotSD = true;

// var dummyElement_n = 27;
  // plot size and boundaries

  var margin ={top:40, right: 20, bottom:100, left: 100};
  var width =  (r+border) * cols + border, // width of tile plot
      height =  (r+border) * rows + border , // height of tile plot
      w = width + margin.left + margin.right + colW,  // width of svg
      h = height + margin.top + margin.bottom;        // width of svg


  // Create scales and axis
  var color4Mean = d3.scale.linear()
                      .domain([0,d3.max(d3.merge(areaPerformances.Jonah.respEpochLOOCV_mean))])
                      .interpolate(d3.interpolateHsl)
                      .range(["hsl(62,100%,90%)", "hsl(222,30%,20%)"]);
  var color4SD = d3.scale.linear()
                      .domain([d3.min(d3.merge(areaPerformances.Jonah.respEpochLOOCV_std)),d3.max(d3.merge(areaPerformances.Jonah.respEpochLOOCV_std))])
                      .interpolate(d3.interpolateRgb)
                      .range(['#f6faaa','#9E0142']);


  var xScale = d3.scale.ordinal()
                  .domain(d3.range(cols))
                  .rangeRoundBands([0, width],.1);

  var yScale = d3.scale.ordinal()
                  .domain(d3.range(rows))
                  .rangeRoundBands([0, height],.1);

  var xAxis = d3.svg.axis()
                .scale(xScale)
                .orient("bottom")
                .tickFormat(function(d,i){ return areaPerformances.signalLabels[i];}) // hide tick labels
                .tickSize(5,0); // hide outter ticks in d3

  var yAxis = d3.svg.axis()
                .scale(yScale)
                .orient("left")
                .tickFormat(function(d,i){ return areaPerformances.areaLabels[i];})
                .tickSize(5,0);


  var vis = d3.select("#graph").append("svg")
              .attr("width", w)
              .attr("height", h);

  var tiles = vis.append("g")
              .attr("id","tiles")
              .attr("transform","translate(" + margin.left + "," + margin.top + ")");

// Append axes to graph

  tiles.append("g")
    .attr("class","axis")
    .attr("transform", "translate(-1.5," + (height -1.5) + ")")
    .call(xAxis)
    .selectAll("text")
      .style("text-anchor","end")
      .attr("dx","-.8em")
      .attr("dy",".15em")
      .attr("transform", function(d) { return "rotate(-65)";});

  tiles.append("g")
    .attr("class","axis")
    .attr("transform","translate(" + (xScale(0) - border) + ",0)")
    .call(yAxis);

  tiles.append("g")
    .attr("class", "tile title")
    .attr("transform","translate(" + xScale(Math.floor(cols/2)) + ",-5)")
    .append("text")
    .text("Monkey J")
    .style("text-anchor","start");


  // Plot one tile per element

 tiles.selectAll("rect")
   .data(d3.merge(areaPerformances.Jonah.respEpochLOOCV_mean))
   .enter()
   .append("rect")
   .attr("x", function(d,i) { return xScale(i % cols); })
   .attr("y", function(d,i) { return yScale(Math.floor(i/cols)); })
   .attr("width", r)
   .attr("height", r)
   .attr("fill", function(d,i){ return color4Mean(d);})
   .attr("stroke-width",function(d){ if(plotSD) {return 3;} else{return 0;}})
   .attr("stroke", function(d,i){ return color4SD(d3.merge(areaPerformances.Jonah.respEpochLOOCV_std)[i]); });

// plot colorbars
  var colorBarScale4Mean = d3.scale.linear()
                      .domain([height,0])
                      .interpolate(d3.interpolateHsl)
                      .range(["hsl(62,100%,90%)", "hsl(222,30%,20%)"]);


 var tempScale4Mean = d3.scale.linear().domain([d3.max(d3.merge(areaPerformances.Jonah.respEpochLOOCV_mean)),0])
                  .rangeRound([0, height]);

  var colorAxis4Mean = d3.svg.axis()
                .scale(tempScale4Mean)
                .ticks(5)
                .tickSize(3,3)
                .orient("right");

  var colorBar4Mean = vis.append("g")
                    .attr("id","colorBar")
                    .attr("transform","translate(" + (w - colW -10) + "," + margin.top + ")");


  colorBar4Mean.selectAll("rect")
    .data(d3.range(0,height+1))
    .enter()
    .append("rect")
    .attr("x", 0)
    .attr("y",function(d,i){ return  i;})
    .attr("width", r/2)
    .attr("height",2)
    .attr("fill", function(d,i){ return colorBarScale4Mean(i); });

// colorbar axis for mean
  colorBar4Mean.append("g")
    .attr("class","c axis")
    .attr("transform","translate(" + (r/2) +  ",0)")
    .call(colorAxis4Mean)
    .append("text")
    .attr("x",height/2)
    .attr("y",-20)
    .attr("transform", "rotate(90)")
    .style("text-anchor","middle")
    .text("Mean")

//colorbar axis for S.D

if (plotSD){
    var colorBarScale4SD = d3.scale.linear()
                        .domain([height,0])
                        .interpolate(d3.interpolateRgb)
                        .range(['#f6faaa','#9E0142']);


    var tempScale4SD = d3.scale.linear().domain([d3.max(d3.merge(areaPerformances.Jonah.respEpochLOOCV_std)),0])
                    .rangeRound([0, height]);

    var colorAxis4SD = d3.svg.axis()
                  .scale(tempScale4SD)
                  .ticks(5)
                  .tickSize(3,3)
                  .orient("right");

    var colorBar4SD = vis.append("g")
                      .attr("id","colorBar")
                      .attr("transform","translate(" + (w - colW/2 ) + "," + margin.top + ")");


    colorBar4SD.selectAll("rect")
        .data(d3.range(0,height+1))
        .enter()
        .append("rect")
        .attr("x", 0)
        .attr("y",function(d,i){ return  i;})
        .attr("width", r/2)
        .attr("height",2)
        .attr("fill", function(d,i){ return colorBarScale4SD(i); });

    // colorbar axis for S.D.
    colorBar4SD.append("g")
        .attr("class","c axis")
        .attr("transform","translate(" + (r/2) +  ",0)")
        .call(colorAxis4SD)
        .append("text")
        .attr("x",height/2)
        .attr("y",-15)
        .attr("transform", "rotate(90)")
        .style("text-anchor","middle")
        .text("S.D.");
  }

}

