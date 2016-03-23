# Global helpers
Template.registerHelper "boolString", (b) ->
  String(b)

Template.registerHelper "daysAgo", (d) ->
  "10 days ago"

Template.registerHelper "uniqueID", (t,s) ->
  t + s

Template.registerHelper "fontAwesome", (name) ->
  Spacebars.SafeString('<i class="fa fa-' + name + '"></i>');

Template.registerHelper "getRealName", (userId) ->
  Meteor.users.findOne(userId).profile.firstName

Template.registerHelper "getLabel", (value,parameter) ->
  _.findWhere(Schemas.SpdxLicense.schema(parameter).autoform.afFieldInput.options, value: value).label

Template.registerHelper "debug", (optionalValue) ->
    console.log("Current Context")
    console.log("====================")
    console.log(this)

    if optionalValue
      console.log("Value")
      console.log("====================")
      console.log(optionalValue)
