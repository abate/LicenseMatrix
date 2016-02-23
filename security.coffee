
Security.defineMethod 'ifIsOwner',
  fetch: []
  transform: null
  deny: (type, arg, userId, doc) ->
    doc.submittedBy == undefined and
    userId != doc.submittedBy

Security.defineMethod "ifIsCurrentUser",
  fetch: []
  transform: null
  deny: (type, arg, userId, doc) ->
    userId != doc._id

# a user can update a compatibility information, but only editors and admin ca
# verify the information
LicenseMatrix.permit('insert').ifLoggedIn().exceptProps(['verified','verifiedBy']).apply()
LicenseMatrix.permit('update').ifIsOwner().exceptProps(['verified','verifiedBy']).apply()
LicenseMatrix.permit('update').ifHasRole(['admin','editor']).apply()
LicenseMatrix.permit(['insert','update']).apply()

# all users can add a row in the moderation table, but only editors and
# admins can remove or update
ModerationTable.permit('insert').ifLoggedIn().apply()
ModerationTable.permit(['remove','update']).ifHasRole(['admin','editor']).apply()
# ModerationTable.permit(['insert','update']).apply()

Security.permit(['remove','update']).collections([ Meteor.users ]).ifHasRole(['admin']).apply();
Security.permit(['update']).collections([ Meteor.users ]).ifIsCurrentUser().apply();
