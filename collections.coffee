console.log "collections"
@LicenseMatrix = new Mongo.Collection 'Licensematrix'
@SpdxLicense = new Mongo.Collection 'Spdxlicense'
@LicenseMatrixTable = new Mongo.Collection "Licensematrixtable"

Schemas = {}

Schemas.SpdxLicense = new SimpleSchema(
  name:
    type: String
    label: 'The Name of the License'
  url:
    type: String
    label: 'the url to retrive the License'
    optional: true
    #custom: () -> this.value
  osiApproved:
    type: Boolean
    label: 'True if the License OSI approved'
  id:
    type: String
    label: 'The SPDX License ID'
)

SpdxLicense.attachSchema(Schemas.SpdxLicense)

Schemas.LicenseMatrix = new SimpleSchema(
  id1:
    type: Schemas.SpdxLicense
    label: "License"
  id2:
    type: Schemas.SpdxLicense
    label: "License"
  compatibility:
    type: String
    allowedValues: ["Compatible","InCompatible","ReLicense","Unknown"]
    label: "Compatibility"
  comments:
    type: String
    label: "Comments"
    optional: true
)

LicenseMatrix.attachSchema(Schemas.LicenseMatrix)

LicenseMatrix.allow {
  insert: () -> true
  update: () -> true
  remove: () -> true
}

Meteor.isServer and Meteor.publish "Licensematrix", () -> LicenseMatrix.find()
Meteor.isServer and Meteor.publish "SpdxLicense", () -> SpdxLicense.find()
Meteor.isServer and Meteor.publish "LicenseMatrixTable", () -> LicenseMatrixTable.find()

Meteor.isClient and Meteor.subscribe "Licensematrix"
Meteor.isClient and Meteor.subscribe "SpdxLicense"
Meteor.isClient and Meteor.subscribe "LicenseMatrixTable"
