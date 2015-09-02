# Description:
#   Farm Class
#
# Commands:
#
#
# Notes:
#

_ = require 'lodash'
logger = require '../lib/_logger'

class Farm 

  constructor: (name, location, aliases) ->
    @name = name
    @location = location
    
    if aliases and aliases.constructor == Array
      @aliases = aliases
    else
      @aliases = [];
  
  # Functions (Fat arrow to lock in context of invocation to Farm instance, no @ symbol to denote instance function)
  showInfo: => 
    logger.log "#{@name} #{@location} #{@aliases}"
    
  setIntelLocationLink: (link) =>
    @location = link
  
  addAlias: (newAlias) =>
    
    if @aliases.length == 0
      @aliases.push(newAlias)
    else
      result = _.find @aliases, (alias) ->
        return alias == newAlias
      if !result
        @aliases.push(newAlias)
  
  removeAlias: (aliasToRemove) =>
    aliasToRemove = aliasToRemove
    if @aliases.length == 0
      return @aliases
    else
      console.log "Removing #{aliasToRemove}"
      @aliases = _.without(@aliases, aliasToRemove)
      console.log @aliases
      return @aliases
  
        
  print: =>
    return "Name: *\"#{@name}\"* | Aliases *[#{@aliases}]* | *Intel link:* #{@location}"
  
  # Static class function (Class method) - Takes in a string to match and an array of strings to match against
  @matchAlias: (string, array) =>
    # Build an or'd string out of the array of strings
    arr = array.join '\\b|\\b'
    regex = new RegExp "\\b#{arr}\\b", 'i'
    console.log regex
    console.log(regex.test string)
    logger.log "Checking #{string} against: #{regex}" 
    logger.log(regex.test string)
    
    return regex.test string
  
module.exports = Farm
  