# Description:
#   Flash farm stuff
#
# Commands:
#
#
# Notes:
#

_ = require 'lodash'
logger = require '../lib/_logger'


module.exports = (robot) ->
  
  # Roster of those who are in the flash and the flash object
  # TODO: Turn into a class
  robot.brain.data.flash ?= {}
  robot.brain.data.flash.flash_roster ?= []
  
  # backup roster just in case it gets cleared by accident
  robot.brain.data.flash._flash_roster ?= []

  usernamePattern = ///
       @*              # @ symbol
       ([\w-]+)        # letters, numbers, underscore, or -
       ///i            #end of line and ignore case
    
  roster =
    add: (username) ->
      if username.match usernamePattern
        if username not in robot.brain.data.flash.flash_roster
          robot.brain.data.flash.flash_roster.push username
      else 
          # logger.log "Usernames do not match"
    remove: (username) ->
      if username.match usernamePattern
        # remove it from robot brain if it's there
        robot.brain.data.flash.flash_roster = (user for user in robot.brain.data.flash.flash_roster when user != username)
        # logger.log username + ' removed from roster'
      else
        # logger.log "Usernames do not match"
    clear: () ->
      robot.brain.data.flash._flash_roster = robot.brain.data.flash.flash_roster
      robot.brain.data.flash.flash_roster = []
      # logger.log 'Flash roster cleared'
    list: () ->
      ret = []
      for user in robot.brain.data.flash.flash_roster
        ret = ret + "*#{user}* "
        # logger.log "*#{user}*"
      ret ?= []
    count: () ->
      count = robot.brain.data.flash.flash_roster.length
      if !count then count = 0
      count ?= []

  event =
    setFoodTime: (value) ->
      robot.brain.data.flash.foodTime = value
    setFlashTime: (value) ->
      robot.brain.data.flash.flashTime = value
    setFoodLocation: (value) ->
      robot.brain.data.flash.foodLocation = value
    setFlashLocation: (value) ->
      robot.brain.data.flash.flashLocation = value
    setFoodLink: (value) ->
      robot.brain.data.flash.foodLink = value
    setFlashLink: (value) ->
      robot.brain.data.flash.flashLink = value
    clearFoodTime: () ->
      robot.brain.data.flash.foodTime = null
    clearFlashTime: () ->
      robot.brain.data.flash.flashTime = null
    clearLocation: () ->
      robot.brain.data.flash.foodLocation = null
    clearLocation: () ->
      robot.brain.data.flash.flashLocation = null
    clearLink: () ->
      robot.brain.data.flash.foodLocationLink = null
    clearLink: () ->
      robot.brain.data.flash.flashLocationLink = null
    getFoodTime: () ->
      robot.brain.data.flash.foodTime ?= []
    getFlashTime: () ->
      robot.brain.data.flash.flashTime ?= []
    getFoodLocation: () ->
      robot.brain.data.flash.foodLocation ?= []
    getFlashLocation: () ->
      robot.brain.data.flash.flashLocation ?= []
    getFoodLink: () ->
      robot.brain.data.flash.foodLink ?= []
    getFlashLink: () ->
      robot.brain.data.flash.flashLink ?= []
    getEvent: () ->
      msg = ""
      if (robot.brain.data.flash.foodTime && robot.brain.data.flash.foodLocation)
        msg = "Food: " + robot.brain.data.flash.foodLocation
        if (robot.brain.data.flash.foodLink)
          msg = msg + " (" + robot.brain.data.flash.foodLink+")"
        msg = msg + " @" + robot.brain.data.flash.foodTime
      if (robot.brain.data.flash.flashTime && robot.brain.data.flash.flashLocation)
        msg = "Flash: " + robot.brain.data.flash.flashLocation
        if (robot.brain.data.flash.flashLink)
          msg = msg + " (" + robot.brain.data.flash.flashLink+")"
        msg = msg + " @" + robot.brain.data.flash.flashTime
      msg ?= []

    

  # flash count in command, listens for "flash count me in"
  robot.hear /\bflash\s+count\s+me\s+in\b/i, (res) ->
    roster.add(res.envelope.user.name)
    response = " *#{res.envelope.user.name}* added to the flash roster! You are now up to *#{roster.count()}* member(s): " + roster.list()
    return res.send response

  # flash count in command, listens for "flash countin", then checks the rest of the string if it's a valid command
  robot.hear /\bflash\s+count\s+in\s(.+)\b/i, (res) ->
    # logger.log 'Res: '
    # logger.log res
    #
    # logger.log 'Rest of the line:'
    # logger.log res.match[1]
    
    remainder = res.match[1].trim()
    
    # split the remainder into an array delimited by spaces
    usernames = remainder.split " "

    # logger.log usernames
    
    response = ""
    
    for username in usernames 
      # Translate me or i into the user sending the meesage
      if username.match /^(i|me)$/ig
        username = res.envelope.user.name
      roster.add(username)
      response = "#{response} *#{username}*"

    response = response + " added to the flash roster! You are now up to *#{roster.count()}* member(s): " + roster.list()
    logger.log robot.brain.data.flash.flash_roster
    
    return res.send response
    
  # flash count me out command, listens for "flash count me out"
  robot.hear /\bflash\s+count\s+me\s+out\b/i, (res) ->
    roster.remove(res.envelope.user.name)
    response = " *#{res.envelope.user.name}* removed from the flash roster! You are now down to *#{roster.count()}* member(s): " + roster.list()
    return res.send response
    
  # flash count out command, listens for "flash count out", then checks the rest of the string if it's a valid command
  robot.hear /\bflash\s+count\s+out\s(.+)\b/i, (res) ->
    # logger.log 'Res: '
    # logger.log res
    #
    # logger.log 'Rest of the line:'
    # logger.log res.match[1]
  
    remainder = res.match[1].trim()
  
    # split the remainder into an array delimited by spaces
    usernames = remainder.split " "
  
    # logger.log usernames
    
    response = ""
  
    for username in usernames 
      # Translate me or i into the user sending the meesage
      if username.match /^(i|me)$/ig
        username = res.envelope.user.name
      roster.remove(username)
      response = "#{response} *#{username}*"
  
    # logger.log robot.brain.data.flash.flash_roster
    
    response = response + " removed from the flash roster! You are now down to *#{roster.count()}* member(s): " + roster.list()
    
    return res.send response
    
  # flash set command: listens to "flash set location" and "flash set location link"
  robot.hear /\bflash\s+set\s+(loc(?:ation){0,1}\s*(?:link)*)+\b(.+)\b/i, (res) ->
    # logger.log 'Res: '
    # logger.log res
    #
    # logger.log 'Rest of the line:'
    # logger.log res.match[2]

    option = ""
    value = ""

    option = res.match[1].trim()
    # logger.log 'Option: ' + option
    
    value = res.match[2].trim()
    # logger.log 'Value: ' + value
    
    response = ""
    
    if option.match /link/i
      robot.brain.data.flash.locationLink = value
      # logger.log robot.brain.data.flash
      response = "Flash location link set to *#{value}*"
    else
      robot.brain.data.flash.location = value
      # logger.log robot.brain.data.flash
      response = "Flash location set to *#{value}*"
    
    return res.send response
    
  
  # flash clear command: listens to "flash clear", "flash clear all", "flash clear location" and "flash clear roster"

  robot.hear /\bflash\s+clear\s+(all|loc(?:ation){0,1}|roster)\b/i, (res) ->
    # logger.log 'Res: '
    # logger.log res
    #
    # logger.log 'Rest of the line:'
    # logger.log res.match[1]
    
    option = ""
    response = ""

    option = res.match[1].trim()
    # logger.log 'Option: ' + option
    
    # reset all items
    if option.match /all/i
      robot.brain.data.flash = {}
      robot.brain.data.flash.location = null
      robot.brain.data.flash.locationlink = null
      roster.clear()      
      response = "All flash information cleared!"
    else if option.match /loc/i
      robot.brain.data.flash.location = null
      robot.brain.data.flash.locationLink = null
      logger.log 'Flash location data cleared'
      response = "All flash location data cleared!"
      
    else if option.match /roster/i
      roster.clear()
      response = "Flash roster cleared!"
    
    # logger.log robot.brain.data.flash
    return res.send response
    
  # flash show command: listens to "flash show"

  robot.hear /\bflash\s+show\s+(info|loc(?:ation){0,1}|roster)\b/i, (res) ->
    # logger.log 'Res: '
    # logger.log res
    #
    # logger.log 'Rest of the line:'
    # logger.log res.match[1]
    
    option = ""
    option = res.match[1].trim()
    location = robot.brain.data.flash.location
    
    response = "Your flash"
    if robot.brain.data.flash.location?
      response = "Your flash at *#{location}*"
      if robot.brain.data.flash.locationLink?
        response = response + " (" + robot.brain.data.flash.locationLink + ")"
    
    response = response + " currently has *#{roster.count()}* member(s): " + roster.list()
    # logger.log response

    # logger.log robot.brain.data.flash
    return res.send response
