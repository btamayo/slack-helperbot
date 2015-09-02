# Description:
#   Utility and debugging
#
# Commands:
#
#
# Notes:
#

fs = require 'fs'
Farm = require './_farm'
_ = require 'lodash'
logger = require '../lib/_logger'

module.exports = (robot) ->

  # TODO: Use redis to store locations and allow users to 'teach' the bot where locations are, don't match against hard-coded strings anymore (use another regex instead)

  billBarber_location = "https://www.ingress.com/intel?ll=33.688219,-117.823842&z=16"
  veterans_location = "https://www.ingress.com/intel?ll=33.602257,-117.65262&z=17"
  tustin_location = "https://www.ingress.com/intel?ll=33.744593,-117.823648&z=15"
  delMar_location = "https://www.ingress.com/intel?ll=33.424412,-117.617848&z=16"
  balboaIsland_location = "https://www.ingress.com/intel?ll=33.60605,-117.889802&z=16"
  theWall_location = "https://www.ingress.com/intel?ll=33.640964,-117.918588&z=18"
  PAC_location = "https://www.ingress.com/intel?ll=33.691102,-117.881786&z=17"
  hh_location = "https://www.ingress.com/intel?ll=33.646979,-117.689635&z=18"
  ow_location = "https://www.ingress.com/intel?ll=33.732995,-117.995537&z=17"
  gwc_location = "https://www.ingress.com/intel?ll=33.733325,-118.003219&z=17"
  soka_location = "https://www.ingress.com/intel?ll=33.554633,-117.734368&z=17"
  mvcc_location = "https://www.ingress.com/intel?ll=33.59625,-117.658821&z=19"
  greatPark_location = "https://www.ingress.com/intel?ll=33.672818,-117.745697&z=17"
  occ_location = "https://www.ingress.com/intel?ll=33.669921,-117.911658&z=17"
  downey_location = "https://www.ingress.com/intel?ll=33.939597,-118.130065&z=17"
  
  # Farm inquiry (seed for OC farms)
  bb_farm        = new Farm("Bill Barber Park", billBarber_location, ['bb', 'bill barber', 'icc']);
  veterans_farm  = new Farm("Veterans", veterans_location, ['vets', 'veterans', 'bears']);
  tustin_farm    = new Farm("Tustin", tustin_location, ['tustin']);
  sc_farm        = new Farm("San Clemente", delMar_location, ['sc', 'del mar', 'san clemente']);
  bi_farm        = new Farm "Balboa Island", balboaIsland_location, ['bi', 'balboa', 'the island', 'balboa island', 'lbi']
  theWall_farm   = new Farm "the Wall", theWall_location, ['the wall']
  PAC_farm       = new Farm "PAC", PAC_location, ['PAC', 'segerstrom']
  hh_farm        = new Farm "Heritage Hill Park", hh_location, ['hh', 'heritage hill']
  ow_farm        = new Farm "Old World", ow_location, ['old world', 'ow']
  gwc_farm       = new Farm "Goldenwest College", gwc_location, ['gwc', 'goldenwest', 'gw']
  soka_farm      = new Farm "Soka University", soka_location, ['soka']
  mvcc_farm      = new Farm "Mission Viejo Community Center", mvcc_location, ['mvcc']
  greatPark_farm = new Farm "Great Park, Irvine", greatPark_location, ['great park']
  occ_farm       = new Farm "Orange Coast College", occ_location, ['occ']
  downey_farm    = new Farm "Downey Civic Center", downey_location, ['downey']
  
  localFarms = []
  
  firstLoad = true
  robot.brain.on 'loaded', ->
    firstLoad = false
    console.log "Brain on loaded event: "
    console.log robot.brain.data.localFarms
    if robot.brain.data.localFarms.length == 0
      console.log "Pushing seed data."
      
      seedFarms = [bb_farm, veterans_farm, tustin_farm, sc_farm, bi_farm, theWall_farm, PAC_farm, hh_farm, gwc_farm, ow_farm, soka_farm, mvcc_farm, greatPark_farm, occ_farm, downey_farm]
      
      _.forEach(seedFarms, (farm) ->
          robot.brain.data.localFarms.push(farm)
      )
      robot.brain.data.localFarms = localFarms
    else
      console.log "Rehydrating redis data."
      # Reinit all farms
      _.forEach(robot.brain.data.localFarms, (farm) ->
        console.log farm
        localFarms.push(new Farm(farm.name, farm.location, farm.aliases))
      )
      console.log localFarms
  
  # TODO: Choose between a generalizable regex (stricter), or create a regex out of known farm aliases (more matches, more array iterations)
  farm_inquire_regex = ///
          \b
          (Where|How)+                       # First group must inquire
          ([']+s|[\s]+is|\u2019s|\u0027s){1} # 's or [space]is or unicode character right end quote
          \s                                 # space
          ([\w-\s]+)                         # rest of sentence
          ///i                                  
  
  robot.hear farm_inquire_regex, (res) ->
    
    # logger.log "Heard you!"
    logger.log res.match[1]
    logger.log res.match[2]
    logger.log res.match[3]
    logger.log res.match[4]
    
    rest = res.match[3]
    logger.log rest
    
    # Get the first word of the rest of the sentence and try to match it, if not, do it for two words
    wordsarr = rest.split " " # split into an array of words
    logger.log "wordsarr:"
    logger.log wordsarr
    
    MAX_MESSAGE_LENGTH = 5 # Arbitrary number for when we decide that they're not asking casually about a place
    
    if wordsarr.length >= MAX_MESSAGE_LENGTH
      return
    
    # Start looking, first start with the first word
    found = false
    word = wordsarr[0] # index of first word
    index = 0
    
    # Check against the aliases of all farms
    # TODO: Change from for each to normal for loop
    find = ->
      _.forEach localFarms, (n) ->
        logger.log "Current word: #{word}"
        if !found && index != wordsarr.length
          if Farm.matchAlias word, n.aliases
            logger.log n.name
            logger.log "Match Found with #{n.name}"
            response = "Here's a quick link to #{n.name}! #{n.location}"
            found = true
            res.send response
      index = index + 1
      word = "#{word} #{wordsarr[index]}"

    find() while (index != wordsarr.length && !found) 
    find = null
    found = null
    wordsarr = null
  
  
  # print all farms
  robot.respond /(print all farms)/i, (res) ->
    
    response = ""
    _.forEach localFarms, (n) ->
      console.log n
      print = n.print()
      response = response.concat("#{print}\n")
    
    # response = response.concat("```")
    res.send response
  
  # Create new farm
  robot.respond /(Farm:|Farm){1}\s(create|add alias|remove alias|print|update link|update name)\s(?:\u201C|\"|\u0022)(.*?)(?:\"|\u0022|\u201D)(.*)/i, (res) ->
    
    console.log "match[0]: #{res.match[0]}"
    console.log "match[1]: #{res.match[1]}"
    console.log "match[2]: #{res.match[2]}"
    
    option = res.match[2]
    
    # Create new farm
    if option == "create"
      if !res.match[3]
        return
        
      farmname = res.match[3]
      console.log "Creating farm named: #{farmname}"
    
      # Check for existence
      duplicate = false
      _.forEach localFarms, (n) ->
        console.log "Checking #{n.name} against #{farmname}"
        if n.name.toUpperCase() == farmname.toUpperCase()
          duplicate = true
          console.log "Farm already exists with name: #{farmname}"
          res.send "Farm already exists with name: #{farmname}"
          return
      
        if Farm.matchAlias farmname, n.aliases
          duplicate = true
          console.log "This farm name already exists as a nickname in: #{n.name}"
          res.send "This farm name already exists as a nickname in: #{n.name}"
          return
    
      if duplicate
        return
        
      # Else we can create it
      # First check the remainder of the params:
      remainder = res.match[4]
      
      aliaslistregex = ///
        (?:.*?)         # Random subsequence before opening bracket
        (?:[\[])        # Finding opening bracket
        (.*?)           # list of aliases
        (?:[\]])        # Ending bracket
        (.*)            # Intel link
      ///i

      intelregex = ///
        (?:.*?)                                 
        (?:\u201C|\"|\u0022)
        (https://www.ingress.com/intel(.*)*?)
        (?:\"|\u0022|\u201D)
        (?:.*)
      ///i
    
      matches = remainder.match aliaslistregex
      console.log matches
    
      if !matches[1]
        console.log "Alias list incorrectly formatted."
        return
    
      aliasstring = matches[1]
      aliasesarr = aliasstring.split(", ")
    
      console.log "New array of aliases: "
      console.log aliasesarr
    
      console.log "Rest of command pt2: #{matches[2]}"
      console.log intelregex
      intellink = matches[2].match intelregex
    
      if !intellink[1]
        console.log "Intel link badly formatted or missing."
        return
    
      newFarm = new Farm(farmname, intellink[1], aliasesarr)
      localFarms.push newFarm
      
      # Update redis b/c why not
      robot.brain.data.localFarms.push newFarm
      
      console.log "New farm created!"
      console.log newFarm.print()
      response = newFarm.print()
      res.send response
      return
      
    
    if option == "add alias" or option == "remove alias"
      farmname = res.match[3]
      remainder = res.match[4]
      
      console.log "Add/Remove alias remainder: #{remainder}"
      
      singleAliasRegex = ///
        (?:.*?)
        (?:\u201C|\"|\u0022)
        (.*)                    # Single Alias
        (?:\"|\u0022|\u201D)
      ///i
      
      if farmname
        console.log "Finding farm name #{farmname}"
        matches = remainder.match singleAliasRegex
        
        if !matches[1]
          response =  "I don't know what alias you're trying to add or remove to #{farmname}. Please use this format: Farm [add|remove] alias \"[FARM PROPER NAME - not alias]\" \"[NEW ALIAS - don't forget to double quotes!|ALIAS TO REMOVE]\""
          console.log response
          res.send response
          return
          
        singleAlias = matches[1]
    
        console.log "Trying to add alias: #{singleAlias} to #{farmname}"
      
        farm = null
        
        _.forEach localFarms, (n) ->
          console.log "Checking #{n.name} against #{farmname}"
          if n.name.toUpperCase() == farmname.toUpperCase()
            farm = n
        
        if !farm
          response = "Sorry, I didn't find #{farmname} in my list. Please use the proper farm names when adding/removing aliases. To check the list and the names, say \"@helperbot: print all farms\""
          console.log response
          res.send response
          return
        
        if option == "add alias"
          console.log "Adding alias: "
          farm.addAlias singleAlias
        else if option == "remove alias"
          console.log "Removing alias: "
          farm.removeAlias singleAlias
          
        console.log "Success!"
        farm.print()
        res.send farm.print()
        return
      
      return
      
      
    if option == "print"
      if !res.match[3]
        res.send "Please supply the name of the farm to print. If you'd like to see all the names and aliases, use \"@helperbot: print all farms\""
        return
      
      farmname = res.match[3]
      
      farm = null
      _.forEach localFarms, (n) ->
        console.log "Checking #{n.name} against #{farmname}"
        if n.name.toUpperCase() == farmname.toUpperCase()
          farm = n
      
      if !farm
        res.send "Sorry #{farmname} not found."
        return
        
      res.send farm.print()
      return
      
    if option == "update link"
      if !res.match[3]
        res.send "Please supply the name of the farm to print. If you'd like to see all the names and aliases, use \"@helper-bot: print all farms\""
        return
      
      farmname = res.match[3]
      remainder = res.match[4]
      
      farm = null
      _.forEach localFarms, (n) ->
        console.log "Checking #{n.name} against #{farmname}"
        if n.name.toUpperCase() == farmname.toUpperCase()
          farm = n
      
      if !farm
        res.send "Sorry #{farmname} not found."
        return
        
      intelregex = ///
        (?:.*?)                                 
        (?:\u201C|\"|\u0022)
        (https://www.ingress.com/intel(.*)*?)
        (?:\"|\u0022|\u201D)
        (?:.*)
      ///i
      
      intellink = remainder.match intelregex
    
      if !intellink[1]
        console.log "Intel link badly formatted or missing."
        return
      
      console.log intellink
      
      farm.setIntelLocationLink intellink[1]
      
      console.log "Success!"
      res.send farm.print()
      return
      
    if option == "update name"
      if !res.match[3]
        res.send "Please supply the name of the farm to print. If you'd like to see all the names and aliases, use \"@helper-bot: print all farms\""
        return
      
      farmname = res.match[3]
      remainder = res.match[4]
      
      farm = null
      _.forEach localFarms, (n) ->
        console.log "Checking #{n.name} against #{farmname}"
        if n.name.toUpperCase() == farmname.toUpperCase()
          farm = n
      
      if !farm
        res.send "Sorry #{farmname} not found."
        return
        
      newNameRegex = ///
        (?:.*?)
        (?:\u201C|\"|\u0022)
        (.*)                    # Single Alias
        (?:\"|\u0022|\u201D)
      ///i
      
      newName = remainder.match newNameRegex
    
      if !newName[1]
        console.log "New name badly formatted or missing."
        return
      
      console.log newName
      
      farm.name = newName[1]
      
      console.log "Success!"
      res.send farm.print()
      return