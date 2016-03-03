console.log "server"
fs = Npm.require("fs")
path = Npm.require( 'path' )

Meteor.startup ->
  console.log "startup"

  if SpdxLicense.find().count() == 0
    console.log "Initialization SpdxLicense"
    for c,l of spdxLicenseDict
      SpdxLicense.insert({
        name : l.name
        url: l.url
        osiApproved: l.osiApproved
        spdxid : c
      })

  if LicenseMatrix.find().count() == 0
    console.log "Initialization LicenseMatrix"
    for spdxid1 in spdxLicenseIds[0..5]
      m = { title : spdxid1 }
      idx = 0
      c1 = SpdxLicense.findOne({spdxid: spdxid1})
      for spdxid2 in spdxLicenseIds[0..5]
        col = "lid_" + idx++
        if spdxid1 != spdxid2
          c2 = SpdxLicense.findOne({spdxid: spdxid2})
          d_mirror =
            spdxid1: c2._id
            spdxid2: c1._id
          lm = LicenseMatrix.findOne(d_mirror)
          if lm
            m[col] = null
          else
            m[col] = LicenseMatrix.insert { spdxid1: c1._id, spdxid2: c2._id }
        else
          m[col] = null
      LicenseMatrixTable.insert(m)

  if Meteor.users.find().fetch().length == 0
    console.log 'Creating users: '
    users = [
      { name: 'Admin User', email: 'admin@example.com', roles: ['admin'] }
      { name: 'Normal User', email: 'normal@example.com', roles: ['user'], },
      { name: 'Editor User', email: 'editor@example.com', roles: ['editor'] },
    ]
    for userData in users
      newuser = Accounts.createUser(
        email: userData.email
        password: 'apple1'
        profile:
          firstName: userData.name
        roles: userData.roles
      )
      Roles.addUsersToRoles newuser, userData.roles
  console.log "startup done"

Accounts.onCreateUser (options, user) ->
  # if this is the first user, automatically grant admin rights
  if Meteor.users.find().fetch().length == 0
    user.roles = ['admin']
  if options.profile
    user.profile = options.profile
  user
