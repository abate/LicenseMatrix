
Security.defineMethod 'ifIsOwner',
  fetch: []
  transform: null
  deny: (type, arg, userId, doc) ->
    userId != doc.submittedBy

Security.defineMethod "ifIsCurrentUser",
  fetch: []
  transform: null
  deny: (type, arg, userId, doc) ->
    userId != doc._id

# a user can update a compatibility information, but only editors and admin ca
# verify the information
# LicenseMatrix.permit('update').ifLoggedIn().exceptProps(['verified','verifiedBy']).apply()
# LicenseMatrix.permit('update').ifIsOwner().exceptProps(['verified','verifiedBy']).apply()
LicenseMatrix.permit('update').ifHasRole(['editor','admin']).onlyProps(['verified','verifiedBy','analysis']).apply()

# allow users to add tags
SpdxLicense.permit('update').ifLoggedIn().onlyProps(['tags']).apply()
# allow editos to add categories
SpdxLicense.permit('update').ifHasRole(['editor','admin']).onlyProps(['category']).apply()

# all users can add a row in the moderation table, but only editors and
# admins can remove or update
ModerationTable.permit('insert').ifLoggedIn().apply()
ModerationTable.permit(['remove','update']).ifHasRole(['editor','admin']).apply()

Security.permit(['remove','update']).collections([ Meteor.users ]).ifHasRole(['admin']).apply();
Security.permit(['update']).collections([ Meteor.users ]).ifIsCurrentUser().exceptProps(['roles','emails.0']).apply();
