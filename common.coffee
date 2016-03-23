console.log "common"

ModerationTable.helpers
  username: () -> Meteor.users.findOne(this.submittedBy).profile.firstName
