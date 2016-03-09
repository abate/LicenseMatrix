console.log "collections"
@LicenseMatrix = new Mongo.Collection 'Licensematrix'
@SpdxLicense = new Mongo.Collection 'Spdxlicense'
@ModerationTable = new Mongo.Collection "Moderationtable"
@spdxLicenseIds = Object.keys(spdxLicenseDict)

@Schemas = {}

SimpleSchema.messages
  "AnalysisMismatch": "You must specify both the relation and compatibility type"
  "AnalysisRequired": "You must add at least one compatibility item"

Schemas.LicenseAnalysis = new SimpleSchema(
  relation:
    type: [String]
    allowedValues: [
      "DynamicLinking",
      "StaticLinking",
      "Documentation",
      "RemoteAPI",
      "Compile",
    ]
    label: "Relation Type"
    autoform:
      type: "select"
      afFieldInput:
        options: "allowed"
        # multiple: true
        # tags: true
        # selectOnBlur: true
      afFormGroup:
        'formgroup-class': 'col-sm-6'
    custom: () ->
      if (!this.isSet || this.value == null || this.value == "")
        "AnalysisMismatch"
  compatibility:
    type: [String]
    allowedValues: [
      "Compatible",
      "InCompatible",
      "LeftReLicense",
      "RightReLicense",
    ]
    label: "Compatibility"
    autoform:
      type: "select"
      afFieldInput:
        options: "allowed"
        # multiple: true
        # tags: true
        # selectOnBlur: true
      afFormGroup:
        'formgroup-class': 'col-sm-6'
    custom: () ->
      if (!this.isSet || this.value == null || this.value == "")
        "AnalysisMismatch"
)

LicenseCategory = [
  "Copyleft",
  "Free Software",
  "GPL Compatible",
  "Creative Commons"
]

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
    label: 'The SPDX License ID'
  category:
    type: [String]
    label: 'Category'
    optional: true
    allowedValues: LicenseCategory
    autoform:
      type: "select2"
      afFieldInput:
        options: "allowed"
        multiple: true
        tags: true
        selectOnBlur: true
  tags:
    type: [String],
    label: 'Tags',
    autoform:
      type: 'tagsTypeahead'
    optional: true
)

SpdxLicense.attachSchema(Schemas.SpdxLicense)

licenseSearchOptions = () ->
  a = SpdxLicense.find().map (l) -> {label: l.spdxid, value: "spdx:" + l._id }
  b = CloudspiderTags.find().map (t) -> {label: "tag:" + t.name, value: "tag:" + t.name}
  c = LicenseCategory.map (t) -> {label: "cat:" + t, value: "cat:" + t}
  d = ["true","false"].map (t) -> {label: "osi:" + t , value:"osi:" + t}
  [a...,b...,c...,d...]

Schemas.SpdxLicenseSearch = new SimpleSchema(
  field1:
    type: [String]
    label: 'Rows'
    autoform:
      type: "select2"
      options: licenseSearchOptions
      afFieldInput:
        multiple: true
        tags: true
        selectOnBlur: true
      afFormGroup:
        'formgroup-class': 'col-sm-5'
  field2:
    type: [String]
    label: 'Columns'
    autoform:
      type: "select2"
      options: licenseSearchOptions
      afFieldInput:
        multiple: true
        tags: true
        selectOnBlur: true
      afFormGroup:
        'formgroup-class': 'col-sm-5'
)

Comments.changeSchema (currentSchema) ->
  currentSchema.analysis =
    type: [Schemas.LicenseAnalysis]
    optional: true
    autoform:
      afObjectField:
        bodyClass: 'container-fluid row'
  currentSchema

Schemas.LicenseMatrix = new SimpleSchema(
  spdxid1:
    type: String
    autoform:
      readonly: true
    denyUpdate: true
  spdxid2:
    type: String
    autoform:
      readonly: true
    denyUpdate: true
  analysis:
    type: [Schemas.LicenseAnalysis]
    optional: true
    autoform:
      afObjectField:
        bodyClass: 'container-fluid row'
  verified:
    type: Boolean
    defaultValue: false
    # custom: () ->
    #   if not this.field('analysis').isSet
    #     "AnalysisRequired"
  verifiedBy :
    type: String
    optional: true
    autoValue: () ->
      this.userId
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

@orderIDX = (i,j) ->
  if i.spdxid >= j.spdxid then [i._id,j._id] else [j._id,i._id]

Meteor.isServer and Meteor.publish "Licensematrix", () ->
  # [x,y] = orderIDX(i,j)
  LicenseMatrix.find()
  # {spdxid1:x,spdxid2:y})
# Meteor.isClient and Meteor.subscribe "Licensematrix"

Meteor.isServer and Meteor.publish "Spdxlicense", () -> SpdxLicense.find()
Meteor.isClient and Meteor.subscribe "Spdxlicense"


Meteor.isServer and Meteor.publish "UserDirectory", () ->
  Meteor.users.find {}, {fields: {emails: 1, profile: 1}}

Meteor.isClient and Meteor.subscribe "UserDirectory"
