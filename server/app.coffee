#server only code
console.log "server"

Meteor.startup ->
  console.log "startup"
  console.log "books count " + Books.find().count()

  if Books.find().count() == 0
    licence = {}
    idx = 0
    for c in spdxLicenseIds
      licence["lid_" + idx++] = c

    for cext in spdxLicenseIds
      licence['title'] = cext
      console.log "insert licence" + licence
      Books.insert licence
