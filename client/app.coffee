console.log "on client"

Template.LicenceSwitch.events
  'change .check-out': (a) ->
    selected = a.target.value
    a = $(this)[0].col
    row = $(this)[0].data
    Books.update(row._id, { $set: {"#{ a }": selected} })
    console.log Books.findOne(row._id)

Template.LicenceSwitch.helpers {
    categories: () ->
      [
        {value: 0, name:"Compatible" }
        {value: 1, name:"InCompatible" }
        {value: 2, name:"Re-licence" }
      ]
}
