#= require_self
#= require app/_cars-draggable
#= require app/_cars-forms
#= require app/_cars-cards

window.randomHex = ->
  part = -> Math.floor((1 + Math.random()) * 0x100000).toString(16)
  "#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}"
