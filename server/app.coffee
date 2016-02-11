#server only code
console.log "server"

Meteor.startup ->
  console.log "startup"

  if Books.find().count() == 0
    licence = {}
    idx = 0
    for c in spdxLicenseIds
      licence["lid_" + idx++] = 0

    for cext in spdxLicenseIds
      licence['title'] = cext
      Books.insert licence
