console.log "on client"

Template.FormBlock.helpers
  debug : (optionalValue) ->
    console.log("Current Context")
    console.log("====================")
    console.log(this)

    if optionalValue
      console.log("Value")
      console.log("====================")
      console.log(optionalValue)


Template.spdxLicense.helpers
  debug : (optionalValue) ->
    console.log("Current Context")
    console.log("====================")
    console.log(this)

    if optionalValue
      console.log("Value")
      console.log("====================")
      console.log(optionalValue)


Template.LicenseSwitch.helpers
  compatibility : (id) ->
    if id then LicenseMatrix.findOne(id).compatibility
