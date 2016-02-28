console.log "collections"
@LicenseMatrix = new Mongo.Collection 'Licensematrix'
@SpdxLicense = new Mongo.Collection 'Spdxlicense'
@LicenseMatrixTable = new Mongo.Collection "Licensematrixtable"
@ModerationTable = new Mongo.Collection "Moderationtable"
@spdxLicenseIds = Object.keys(spdxLicenseDict)

Schemas = {}

Schemas.SpdxLicense = new SimpleSchema(
  name:
    type: String
    label: 'The Name of the License'
  url:
    type: String
    label: 'the url to retrive the License'
    optional: true
  osiApproved:
    type: Boolean
    label: 'True if the License OSI approved'
    defaultValue: false
  spdxid:
    type: String
    label: 'The SPDX License ID')

SpdxLicense.attachSchema(Schemas.SpdxLicense)

Schemas.LicenseAnalysis = new SimpleSchema(
  compatibility:
    type: String
    allowedValues: ["Compatible","InCompatible","ReLicense","Unknown"]
    label: "Compatibility"
    autoform:
      afFieldInput:
        type: "select",
        options: "allowed"
  comments:
    type: String
    label: "Comments"
    optional: true
    autoform:
      afFieldInput:
        type: "textarea",
        rows: 10
        class: "form-control input-lg"
  submittedBy:
    type: String
    optional: true
    autoValue: () -> this.userId
    autoform:
      type: "hidden"
  createdAt:
    type: Date
    # denyUpdate: true
    autoValue: () -> new Date()
    autoform:
      type: "hidden"
)

Schemas.LicenseMatrix = new SimpleSchema(
  spdxid1:
    type: String
    autoform:
      readonly: true
  spdxid2:
    type: String
    autoform:
      readonly: true
  analysis:
    type: [Schemas.LicenseAnalysis]
    optional: true
  verified:
    type: Boolean
    defaultValue: false
  verifiedBy :
    type: String
    optional: true
    autoform:
      readonly: true
)

LicenseMatrix.attachSchema(Schemas.LicenseMatrix)

Schemas.UserProfile = new SimpleSchema(
  firstName:
    type: String
    optional: true
  lastName:
    type: String
    optional: true
  organization:
    type: String
    optional: true
  website:
    type: String
    regEx: SimpleSchema.RegEx.Url
    optional: true
  bio:
    type: String
    optional: true
    label: "Biography"
    autoform:
      afFieldInput:
        type: "textarea",
        rows: 10
)

Schemas.User = new SimpleSchema(
  username:
    type: String
    optional: true
    autoform:
      type: "hidden"
  emails:
    type: Array
    optional: true
  'emails.$':
    type: Object
  'emails.$.address':
    type: String
    regEx: SimpleSchema.RegEx.Email
  'emails.$.verified':
    type: Boolean
    optional: true
    autoform:
      type: "hidden"
  createdAt:
    type: Date
    denyUpdate: true
    autoform:
      type: "hidden"
  profile:
    type: Schemas.UserProfile
    optional: true
  services:
    type: Object
    optional: true
    blackbox: true
    autoform:
      type: "hidden"
  roles:
    type: [String],
    allowedValues: ['user','editor', 'admin'],
    autoform:
      afFieldInput:
        type: "select",
        options: "allowed"
    defaultValue: ['user']
)

Meteor.users.attachSchema Schemas.User

Meteor.isServer and Meteor.publish "Licensematrix", () -> LicenseMatrix.find()
Meteor.isServer and Meteor.publish "Spdxlicense", () -> SpdxLicense.find()

Meteor.isClient and Meteor.subscribe "Licensematrix"
Meteor.isClient and Meteor.subscribe "Spdxlicense"

Meteor.isServer and Meteor.publish "UserDirectory", () ->
  Meteor.users.find {}, {fields: {emails: 1, profile: 1}}

Meteor.isClient and Meteor.subscribe "UserDirectory"
