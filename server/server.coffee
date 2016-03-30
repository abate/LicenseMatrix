console.log "server"
fs = Npm.require("fs")
path = Npm.require( 'path' )


Meteor.startup ->
  console.log "startup"

  FedoraLicenseDict = JSON.parse(Assets.getText('fedora.json'))
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
        spdxid : c
      }
      if l.osiApproved == true
        e.categories = ["osi"]
      if LicensesMetadata[c]
        if LicensesMetadata[c].limitations
          e.limitations = LicensesMetadata[c].limitations
        if LicensesMetadata[c].conditions
          e.conditions = LicensesMetadata[c].conditions
        if LicensesMetadata[c].permissions
          e.permissions = LicensesMetadata[c].permissions
      SpdxLicense.insert(e)

    console.log SpdxLicense.find().count()
    for e in FedoraLicenseDict
      if e.fsf == true
        SpdxLicense.update({spdxid: e.spdx},
          {$addToSet: { categories : { $each : ["fsf"]}}})

    # this is the edited data. Overwrite
    for e in SpdxAnnotations
      unless e.tags then e.tags = []
      unless e.categories then e.categories = []
      unless e.limitations then e.limitations = []
      unless e.conditions then e.conditions = []
      unless e.permissions then e.permissions = []
      SpdxLicense.update({spdxid: e.spdxid},
        {$addToSet:
          {tags: { $each: e.tags },
          categories: { $each: e.categories},
          limitations: { $each: e.limitations},
          conditions: { $each: e.conditions},
          permissions: {$each: e.permissions}
          }
        })

  if SpdxLicenseCompatibility.find().count() == 0
    console.log "Initialization SpdxLicenseCompatibility"
    console.log 'Importing private/*.json'
    MatrixData = JSON.parse(Assets.getText('spdx-matrix.json'))

    for e in MatrixData
      e.spdxid1 = SpdxLicense.findOne({spdxid:e.spdxid1})._id
      e.spdxid2 = SpdxLicense.findOne({spdxid:e.spdxid2})._id
      if e.relicenseto
        e.relicenseto = SpdxLicense.findOne({spdxid:e.relicenseto})._id
      SpdxLicenseCompatibility.insert(e)

    gpl2id = SpdxLicense.findOne({spdxid: "GPL-2.0"})._id
    gpl3id = SpdxLicense.findOne({spdxid: "GPL-3.0"})._id
    for e in FedoraLicenseDict
      spdxid1 = SpdxLicense.findOne({spdxid: e.spdx})._id
      if e.gpl2 == true
        SpdxLicenseCompatibility.update({spdxid1: spdxid1, spdxid2: gpl2id},
          {$set : { compatibility : "linking", verified: true}}, { upsert: true })
      else if e.gpl2 == false
        SpdxLicenseCompatibility.update({spdxid1: spdxid1, spdxid2: gpl2id},
          {$set : { compatibility : "notcompatible", verified: true}}, { upsert: true })
      if e.gpl3 == true
        SpdxLicenseCompatibility.update({spdxid1: spdxid1, spdxid2: gpl3id},
          {$set : { compatibility : "linking", verified: true}}, { upsert: true })
      else if e.gpl3 == false
        SpdxLicenseCompatibility.update({spdxid1: spdxid1, spdxid2: gpl3id},
          {$set : { compatibility : "notcompatible", verified: true}}, { upsert: true })

  if Meteor.users.find().fetch().length == 0
    console.log 'Creating users: '
    users = [
      { name: 'Admin User', email: 'admin@example.com', roles: ['admin'] }
      { name: 'Normal User', email: 'normal@example.com', roles: ['user'] },
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
