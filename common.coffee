console.log "common"

ModerationTable.helpers
  username: () -> Meteor.users.findOne(this.submittedBy).profile.firstName

Meteor.methods
  'addLicense': (x,y) ->
    LicenseMatrix.insert ({spdxid1: x, spdxid2: y, analysis: []})
