console.log "collections"
@SpdxLicenseCompatibility = new Mongo.Collection 'Spdxlicensecompatibility'
@SpdxLicense = new Mongo.Collection 'Spdxlicense'
@ModerationTable = new Mongo.Collection "Moderationtable"

@Schemas = {}

SimpleSchema.messages
  "AnalysisMismatch": "You must specify both the relation and compatibility type"
  "AnalysisRequired": "You must add at least one compatibility item"

Schemas.SpdxLicenseCompatibility = new SimpleSchema(
  spdxid1:
    type: String
    autoform:
      label: false
      type: "hidden"
  orlater:
    type: Boolean
    defaultValue: false
    optional: true
    autoform:
      label: "Or Later"
      type: "boolean-checkbox"
  exceptions:
    type: String
    optional: true
    allowedValues: spdxExceptions
    autoform:
      label: false
      placeholder: "Exception"
      afFieldInput:
        type: "selectize"
        options: "allowed"
  compatibility:
    type: String
    allowedValues: LicenseCompatibility.map (e) -> e.value
    autoform:
      label: false
      placeholder: "Compatibility"
      type: "selectize"
      afFieldInput:
        options: LicenseCompatibility
  spdxid2:
    type: String
    autoform:
      type: "selectize"
      placeholder: "With"
      label: false
      afFieldInput:
        options: () ->
          SpdxLicense.find().map (l) -> {label: l.spdxid, value: l._id }
        selectOnBlur: true
  url:
    type: String
    label: 'Source'
    optional: true
  explanation:
    type: String
    optional: true
    label: "Detailed Explanation"
    autoform:
      afFieldInput:
        type: "textarea",
        rows: 10
  verified:
    type: Boolean
    defaultValue: false
    autoform:
      type: "boolean-checkbox"
  submittedBy :
    type: String
    optional: true
    autoform:
      type: "hidden"
    autoValue: () ->
      this.userId
)

SpdxLicenseCompatibility.attachSchema(Schemas.SpdxLicenseCompatibility)

Schemas.SpdxLicense = new SimpleSchema(
  name:
    type: String
    label: 'The Name of the License'
  url:
    type: String
    label: 'the url to retrive the License'
    optional: true
  spdxid:
    type: String
    label: 'The SPDX License ID'
  categories:
    type: [String]
    label: 'Categories'
    optional: true
    allowedValues: LicenseCategory.map (e) -> e.value
    autoform:
      type: "selectize"
      afFieldInput:
        options: LicenseCategory
        multiple: true
        tags: true
        selectOnBlur: true
  conditions:
    type: [String]
    label: 'Conditions'
    optional: true
    allowedValues: LicenseCharacteristic["conditions"].map (e) -> e.tag
    autoform:
      type: "selectize"
      afFieldInput:
        options: LicenseCharacteristic["conditions"].map (e) -> { label: e.label, value: e.tag }
        multiple: true
        tags: true
        selectOnBlur: true
  limitations:
    type: [String]
    label: 'Limitations'
    optional: true
    allowedValues: LicenseCharacteristic["limitations"].map (e) -> e.tag
    autoform:
      type: "selectize"
      afFieldInput:
        options: LicenseCharacteristic["limitations"].map (e) -> { label: e.label, value: e.tag }
        multiple: true
        tags: true
        selectOnBlur: true
  permissions:
    type: [String]
    label: 'Permissions'
    optional: true
    allowedValues: LicenseCharacteristic["permissions"].map (e) -> e.tag
    autoform:
      type: "selectize"
      afFieldInput:
        options: LicenseCharacteristic["permissions"].map (e) -> { label: e.label, value: e.tag }
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
  c = LicenseCategory.map (t) -> {label: "cat:" + t.label, value: "cat:" + t.value}
  l = LicenseCharacteristic['limitations'].map (t) -> {label: "lim:" + t.tag, value: "lim:" + t.tag}
  p = LicenseCharacteristic['permissions'].map (t) -> {label: "perm:" + t.tag, value: "perm:" + t.tag}
  co = LicenseCharacteristic['conditions'].map (t) -> {label: "cond:" + t.tag, value: "cond:" + t.tag}
  d = ["true","false"].map (t) -> {label: "osi:" + t , value:"osi:" + t}
  [a...,b...,c...,d...,l...,co...,p...,]

commonSearchOptionsSelect = () -> [
  {label: "GPL vs GPL", value: "GPLvsGPL"  },
  {label: "Osi vs Osi", value: "OSIvsOSI" },
  {label: "Fsf vs Osi", value: "FSFvsOSI" },
  {label: "Cecile vs GPL", value: "CECILEvsGPL"}
]

@commonSearchOptions = []
commonSearchOptions["GPLvsGPL"] = {field1: ["tag:gpl"], field2: ["tag:gpl"]}
commonSearchOptions["OSIvsOSI"] = {field1: ["cat:osi"], field2: ["cat:osi"]}
commonSearchOptions["FSFvsOSI"] = {field1: ["cat:fsf"], field2: ["cat:osi"]}
commonSearchOptions["CECILEvsGPL"] = {field1: ["tag:cecill"], field2: ["tag:gpl"]}

Schemas.SpdxLicenseSearch = new SimpleSchema(
  commonOptions:
    type: [String]
    label: "Common Licenses Matrix"
    optional: true
    autoform:
      type: "select"
      options: commonSearchOptionsSelect
      afFormGroup:
        'formgroup-class': 'col-sm-12'
  field1:
    type: [String]
    label: 'Rows'
    optional: true
    autoform:
      type: "selectize"
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
    optional: true
    autoform:
      type: "selectize"
      options: licenseSearchOptions
      afFieldInput:
        multiple: true
        tags: true
        selectOnBlur: true
      afFormGroup:
        'formgroup-class': 'col-sm-5'
)

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
    defaultValue: ['user']
    autoform:
      afFieldInput:
        type: "select",
        options: "allowed"
)

Meteor.users.attachSchema Schemas.User

@orderIDX = (i,j) ->
  if i.spdxid >= j.spdxid then [i._id,j._id] else [j._id,i._id]

Meteor.isServer and Meteor.publish "Spdxlicensecompatibility", () ->
  SpdxLicenseCompatibility.find()
Meteor.isClient and Meteor.subscribe "Spdxlicensecompatibility"

Meteor.isServer and Meteor.publish "Spdxlicense", () -> SpdxLicense.find()
Meteor.isClient and Meteor.subscribe "Spdxlicense"

Meteor.isServer and Meteor.publish "UserDirectory", () ->
  Meteor.users.find {}, {fields: {emails: 1, profile: 1}}

Meteor.isClient and Meteor.subscribe "UserDirectory"
