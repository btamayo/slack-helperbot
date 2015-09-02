# Description:
#   Example scripts for you to examine and try out.
#
# Commands:
#   @hubot changelog - show changelog
#   @hubot todo - show to do list and feature requests
#   flash count in <name> [<name>] - Adds names to the current flash roster, takes text (names) separated by spaces
#   flash count out <name> [<name>] - Removes names from the current flash roster, takes text (names) separated by spaces
#   flash show info - Shows current information of the flash
#   flash clear [all|location|roster] - Clears all, location, or roster info (respectively)
#   flash set location <location as text> - Sets the "location" to whatever is in <location as text>
#   @hubot Farm create "FARMNAME" [alias1, alias2, alias3] "https://www.ingress.com/intellinkhere" - THE LIST OF ALIASES NEEDS THE SQUARE BRACKETS. Format (quotation marks, aliases list, and quotation marks on the intel link are important. alias list can be empty. intel link must start with "https://www.ingress.com/intel")
#   @hubot Farm [add alias|remove alias] "FARMNAME" "aliasName" - Quotation marks are important, please use the farm's "proper name" (Might add a way to identify a farm via alias later). Case sensitive for now.
#   @hubot Farm print "FARMNAME" - Prints single info on a farm
#   @hubot print all farms - Prints all farms
#   @hubot Farm update link "FARMNAME" "https://www.ingress.com/intellinkhere" - updates the intel link corresponding to the farm name, e.g. "@hubot: Farm update link "Tustin" "https://www.ingress.com/intel?ll=33.744593,-117.823648&z=15"
#   @hubot Farm update name "FARMNAME" "FARMNAME2" - updates the farm name, e.g. "@hubot: Farm update name "Tustin" "Tustin2"
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

fs = require 'fs'
_ = require 'lodash'


logger = require '../lib/_logger'

module.exports = (robot) ->
  
  robot.brain.data.number_of_beers ?= {}
  robot.brain.data.number_of_wines ?= {}
  
  enterReplies = ['Hi', 'Howdy', 'Ahoy', 'Hi there', 'Good day']
  
  # Enter greetings
  robot.enter (res) ->
    greeting = res.random(enterReplies)
    greeting = greeting + ', *' + res.message.user.name + '*!' + ' Welcome to ' + '*#' + res.message.room + '*.'
    
    logger.log res.message.room
    
    if res.message.room == 'general'
      greeting = greeting + ' If you\'re on the desktop app, please don\'t forget to check out this channel\'s Pinned Posts on the right sidebar.'
    
    res.send greeting
  
  
  # Beer me
  robot.hear /.*(beer me).*/i, (res) ->
    
    user = res.message.user
    beer_count = robot.brain.data.number_of_beers[user.id] ?= 0
    beer_count = beer_count + 1
    
    robot.brain.data.number_of_beers[user.id] = beer_count
    
    if beer_count == 12
      res.send ':beer: You have been beered! You\'re reached alcoholic rank, ' + res.message.user.name + '!'
    else
      res.send ':beer:! You have been beered!'
      
  
  # Wine me
  robot.hear /.*(wine me).*/i, (res) ->
    
    user = res.message.user
    wine_count = robot.brain.data.number_of_wines[user.id] ?= 0
    wine_count = wine_count + 1
    
    robot.brain.data.number_of_wines[user.id] = wine_count
    
    if wine_count == 5
      res.send ':wine_glass: You have been wined! You\'re a wine connoisseur, ' + res.message.user.name + '!'
    else
      res.send ':wine_glass:! You have been wined!'
