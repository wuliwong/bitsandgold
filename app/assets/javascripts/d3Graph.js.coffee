window.d3Graph = (data, width, height, margin) ->
  console.log "d3Graph was called"

  d3.select("svg").remove()

  if (width)
    @w = width
  
  if height
    @h = height
  
  if margin
    @margin = margin

  y = []
  path_names = []
  @N = 0  #number of points contained in the longest data array.
  longest_index = 0 #index of longest data array
  y_max = 0
  max_index = 0

  for i in [0..data.length-1]
    y[i] = d3.scale.linear().domain([0, d3.max(data[i].data)]).range([0 + @margin, @h-@margin])
    path_names[i] = data[i].path_name
    console.log data[i].data.length

    if data[i].data.length > @N
      @N = data[i].data.length #find the longest data array
      longest_index = i
    max = d3.max(data[i].data)
    if max > y_max
      y_max = max
      max_index = i

  x = d3.scale.linear().domain([0,@N]).range([0+@margin, @w-@margin])
  console.log "logging x"
  console.log x
  xformat = (d) -> Math.round(10*d/1440*5)/10 #this puts the ticks in units of days
  translate = "translate(0, " + @h + ")"
  translate_xaxis = "translate(0, " + (@h-@margin) + ")"
  translate_yaxis = "translate(" + @margin + ",0)"

  xAxis = d3.svg.axis().scale(x).ticks(5).tickFormat(xformat)
  yAxis = d3.svg.axis().scale(y[0]).ticks(5).orient("left")

  @vis = d3.select("div.graph_container").append("svg").attr("width",@w).attr("height",@h)

  @g = @vis.append("svg:g").attr("transform", translate);
  line = d3.svg.line().x((d,i) -> return x(i) ).y((d) -> return -1*y[longest_index](d))
  
  @vis.append("svg:g")
    .attr("class","x_axis")
    .attr("transform", translate_xaxis)
    .call(xAxis)

  @vis.append("svg:g")
    .attr("class","y_axis")
    .attr("transform", translate_yaxis)
    .call(yAxis)

  #d3.select("div.graph_container")
  #  .attr("class","axis")
  #  .attr("width",@w)
  #  .attr("height",@h)
  #  .append("g")
  #  .attr("transform", translate)
  #  .call(xAxis)
  #  .call(yAxis)

  color_array = []
  path_name_array = []
  _.each(data, (d)->
    color_array << d.color
    path_name_array << d.path_name
  )

  for i in [0..data.length-1]
    @g.append("svg:path").attr("class", data[i].path_name).attr("d",line(data[i].data)).style("stroke", data[i].color)  

  @g.append("svg:line").attr("x1", x(0)).attr("y1", -1 * y[longest_index](0)).attr("x2", x(w)).attr("y2", -1 * y[longest_index](0))
  @g.append("svg:line").attr("x1", x(0)).attr("y1", -1 * y[longest_index](0)).attr("x2", x(0)).attr("y2", -1 * y[max_index](y_max))

  @x = x

  @color = d3.scale.ordinal().range(color_array)
  
  @legend = @vis.selectAll(".legend")
    .data(path_name_array.slice())
    .enter().append("g")
    .attr("class", "legend")
    .attr("transform", (d, i) ->  return "translate(0," + i * 40 + ")")

  @legend.append("circle")
    .attr("cx", @w - 18)
    .attr("cy", 9)
    .attr("class", "legend_"+path_name_array.slice())
    .attr("r", 5)
    .style("fill", color)

  @legend.append("text")
    .attr("x", @w - 24)
    .attr("y", 9)
    .attr("dy", ".35em")
    .style("text-anchor", "end")
    .text((d) ->  return d)

window.appendPath = (data) ->
  if @g != undefined and @g != null
    for i in [0..data.length-1]
      y = d3.scale.linear().domain([0, d3.max(data[i].data)]).range([0 + @margin, @h-@margin])
      x = d3.scale.linear().domain([0,@N]).range([0+@margin, @w-@margin])
      line = d3.svg.line().x((d,i) -> return x(i) ).y((d) -> return -1*y(d))
      g.append("svg:path").attr("class", data[i].path_name).attr("d",line(data[i].data)).style("stroke", data[i].color)

window.removePath = (path_name) ->
  d3.select("path."+path_name).remove()

