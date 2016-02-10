console.log "on client"

Template.LicenceSwitch.events
  'change .check-out': (a) ->
    selected = a.target.value
    console.log selected
