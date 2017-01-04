
function plotAreaPerformanceMatrix (){

  //SVG boundary parameters
  var w = 1000,
    h = 300,
    borderWidth = 10,
    borderColor = "black";


  // Grid layout parameters

  var cols = 10, // number of columns
    rows = 3, // number of rows
    a    = 20, //  edge length
    r    = 85,//Math.floor(Math.min(w/cols, h/rows)) - a,
    edgeWidth = 10;


  // create SVG element for visualization
  var vis = d3.select("#graph").append("svg")
    .attr("width",w)
    .attr("height",h);

  // // draw border of SVG element
  // var borderPath = vis.append("rect")
  //                     .attr("x",0)
  //                     .attr("y",0)
  //                     .attr("height",h)
  //                     .attr("width",w)
  //                     .style("stroke", borderColor)
  //                     .style("fill","none")
  //                     .style("stroke-width", borderWidth);


  var dummyVar = [[1,2,3,4,5,6,7,8,9,10],
    [11,12,13,14,15,16,17,18,19,20],
    [21,22,23,24,25,26,27,28,29,30]];




  // Creating scales and axis

  var color = d3.scale.linear()
                      .domain([0,1])
                      .interpolate(d3.interpolateHsl)
                      .range(["hsl(62,100%,90%)", "hsl(222,30%,20%)"]);

  var xScale = d3.scale.ordinal()
                  .domain([0,1,2,3,4,5,6,7,8,9])
                  .rangeRoundBands([0, w],.1);
  var yScale = d3.scale.ordinal()
                  .domain([0,1,2])
                  .rangeRoundBands([0, h]);

  var xAxis = d3.svg.axis()
                .scale(xScale)
                .orient("bottom");
 var yAxis = d3.svg.axis()
                .scale(yScale)
                .orient("left");



 // Plot one square per element
  var squares = vis.selectAll("rect")
    .data(d3.merge(dummyVar))
    .enter()
    .append("rect")
    .attr("x", function(d,i) { return xScale(i % cols); })
    .attr("y", function(d,i) { return yScale(Math.floor(i/cols)); })
//    .attr("x", function(d,i) { return borderWidth + parseInt((i % cols)*r); })
//    .attr("y", function(d,i) { return borderWidth + Math.floor(i / cols)*r; })
    .attr("width", r)
    .attr("height", r)
    .attr("stroke-width", edgeWidth)
    .attr("fill", function(d,i){
      return color(Math.random());
    });

// put in text
vis.selectAll("text")
       .data(d3.merge(dummyVar))
       .enter()
       .append("text")
       .text(function(d){ return d;})
       .attr( "text-anchor","middle" )
       .attr("x", function(d,i) { return xScale(i % cols);})
       .attr("y", function(d,i) { return 20+yScale(Math.floor(i/cols)); })
       .attr("font-family","sans-serif")
       .attr("font-size","20px")
       .attr("fill","black");




// plot colorbar

colWidth = 100;
colHeight = 300;
 var colorBar = d3.scale.linear()
                     .domain([0,colHeight])
                     .interpolate(d3.interpolateHsl)
                     .range(["hsl(62,100%,90%)", "hsl(222,30%,20%)"]);

var colBar= d3.select("#graph").append("canvas")
              .attr("width", 1)
              .attr("height", colHeight)
              .style("width", colWidth + "px")
              .style("height", colHeight + "px")
              .each(render);

function render(d) {
  // example from http://bl.ocks.org/mbostock/3014589
  var context = this.getContext("2d"),
      image = context.createImageData(1,colHeight);

  for (var i = 0, j = -1,c; i < colHeight; ++i){
    c=d3.rgb(colorBar(i));
    image.data[++j] = c.r;
    image.data[++j] = c.g;
    image.data[++j] = c.b;
    image.data[++j] = 255;
  }
  context.putImageData(image,0,0);
}
vis.append("g")
    .attr("class","axis")
    .attr("transform","translate(0," + (h - 20) + ")")
    .call(xAxis);

vis.append("g").attr("class","axis")
    .call(yAxis)

}
