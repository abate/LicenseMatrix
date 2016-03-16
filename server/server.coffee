console.log "server"
fs = Npm.require("fs")
path = Npm.require( 'path' )

Meteor.startup ->
  console.log "startup"

  if SpdxLicense.find().count() == 0
    console.log "Initialization SpdxLicense"
    console.log 'Importing private/*.json'
    LicensesMetadata = JSON.parse(Assets.getText('choosealicense.json'))
    SpdxAnnotations = JSON.parse(Assets.getText('spdx-annotation.json'))
    spdxLicenseDict = JSON.parse(Assets.getText('spdx.json'))

    for c,l of spdxLicenseDict
      e = {
        name : l.name
        url: l.url
        osiApproved: l.osiApproved
        spdxid : c
      }
      if LicensesMetadata[c]
        if LicensesMetadata[c].limitations
          e.limitations = LicensesMetadata[c].limitations
        if LicensesMetadata[c].conditions
          e.conditions = LicensesMetadata[c].conditions
        if LicensesMetadata[c].permissions
          e.permissions = LicensesMetadata[c].permissions
      SpdxLicense.insert(e)
    for e in SpdxAnnotations
      SpdxLicense.update({spdxid: e.spdxid},
        {$set:
          {tags: e.tags,
          category: e.category,
          limitations: e.limitations,
          conditions: e.conditions,
          permissions: e.permissions}
        })

  if LicenseMatrix.find().count() == 0
    console.log "Initialization LicenseMatrix"
    console.log 'Importing private/*.json'
    MatrixData = JSON.parse(Assets.getText('spdx-matrix.json'))
    for e in MatrixData
      if e.verified
        LicenseMatrix.insert(e)

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
