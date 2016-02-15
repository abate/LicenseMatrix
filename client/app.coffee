console.log "on client"

Template.LicenceSwitch.events
  'change .check-out': (cell) ->
    selected = cell.target.value
    col = $(this)[0].col
    row = $(this)[0].data
    Books.update(row._id, { $set: {"#{ col }": selected} })

Template.LicenceSwitch.helpers
  'isSelected' : Tracker.nonreactive () ->
    (v,sel) ->
      if parseInt(v) == parseInt(sel)
        "selected"
      else
        ""
