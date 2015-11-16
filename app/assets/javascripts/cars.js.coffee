#= require_self
#= require cars-forms
#= require cars-cards

window.randomHex = ->
  part = -> Math.floor((1 + Math.random()) * 0x100000).toString(16)
  "#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}"
