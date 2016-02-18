#server only code
console.log "server"
fs = Npm.require("fs")
path = Npm.require( 'path' )

Meteor.startup ->
  console.log "startup"

  if SpdxLicense.find().count() == 0
    for c in spdxLicenseIds[0..5]
      SpdxLicense.insert({
        name : c
        url: ""
        osiApproved: false
        id : c
      })

  if LicenseMatrix.find().count() == 0
    for c1 in SpdxLicense.find().fetch()
      for c2 in SpdxLicense.find().fetch()
        if not (c1.id == c2.id)
          LicenseMatrix.insert {
            id1 : c1
            id2 : c2
            compatibility : "Unknown"
          }

  if LicenseMatrixTable.find().count() == 0
    for c1 in spdxLicenseIds[0..5]
      m = { title : c1 }
      idx = 0
      for c2 in spdxLicenseIds[0..5]
        lm = LicenseMatrix.findOne(
          { "id1.name": c1, "id2.name": c2 })
        col = "lid_" + idx++
        m[col] = lm
      LicenseMatrixTable.insert(m)
