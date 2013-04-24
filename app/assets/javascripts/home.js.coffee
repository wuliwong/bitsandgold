# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready () ->
  $("#lookup").click( (e) ->
    e.preventDefault()
    symbol = $("input").val().toUpperCase()
    document.location.href = "/?symbol="+symbol
  )
  $("#lookup-year").click( (e) ->
    e.preventDefault()
    symbol = $("input").val().toUpperCase()
    document.location.href = "/historical/?symbol="+symbol
  )