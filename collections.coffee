console.log "collections"
@LicenseMatrix = new Mongo.Collection 'Licensematrix'
@SpdxLicense = new Mongo.Collection 'Spdxlicense'
@ModerationTable = new Mongo.Collection "Moderationtable"
# @spdxLicenseIds = Object.keys(spdxLicenseDict)

@Schemas = {}

SimpleSchema.messages
  "AnalysisMismatch": "You must specify both the relation and compatibility type"
  "AnalysisRequired": "You must add at least one compatibility item"

Schemas.LicenseAnalysis = new SimpleSchema(
  relation:
    type: [String]
    allowedValues: LicenseReleation.map (e) -> e.value
    label: "Relation Type"
    autoform:
      type: "select"
      afFieldInput:
        options: LicenseReleation
      afFormGroup:
        'formgroup-class': 'col-sm-6'
    # custom: () ->
    #   if (!this.isSet || this.value == null || this.value == "")
    #     "AnalysisMismatch"
  compatibility:
    type: [String]
    allowedValues: LicenseCompatibility.map (e) -> e.value
    label: "Compatibility"
    autoform:
      type: "select"
      afFieldInput:
        options: (e) ->
          console.log e
          console.log Template.instance()
          LicenseCompatibility
      afFormGroup:
        'formgroup-class': 'col-sm-6'
    # custom: () ->
    #   if (!this.isSet || this.value == null || this.value == "")
    #     "AnalysisMismatch"
)

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
    allowedValues: LicenseCategory.map (e) -> e.value
    autoform:
      type: "select2"
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
      type: "select2"
      afFieldInput:
        options: LicenseCharacteristic["conditions"].map (e) -> { label: e.label, value: e.tag }
        multiple: true
        tags: true
        selectOnBlur: true
  limitation:
    type: [String]
    label: 'Limitations'
    optional: true
    allowedValues: LicenseCharacteristic["limitations"].map (e) -> e.tag
    autoform:
      type: "select2"
      afFieldInput:
        options: LicenseCharacteristic["limitations"].map (e) -> { label: e.label, value: e.tag }
        multiple: true
        tags: true
        selectOnBlur: true
  permission:
    type: [String]
    label: 'Permissions'
    optional: true
    allowedValues: LicenseCharacteristic["permissions"].map (e) -> e.tag
    autoform:
      type: "select2"
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
  {label: "Cecile vs GPL", value: "CECILEvsGPL"}
]

@commonSearchOptions = []
commonSearchOptions["GPLvsGPL"] = {field1: ["tag:gpl"], field2: ["tag:gpl"]}
commonSearchOptions["OSIvsOSI"] = {field1: ["osi:true"], field2: ["osi:true"]}
commonSearchOptions["CECILEvsGPL"] = {field1: ["tag:cecill"], field2: ["tag:gpl"]}

Schemas.SpdxLicenseSearch = new SimpleSchema(
  commonOptions:
    type: [String]
    label: "Common Licenses Matrix"
    optional: true
    # custom: () ->
    #   shouldBeRequired = this.field('field1').value == [] && this.field('field2').value == []
    #   if shouldBeRequired
    #     if (!this.isSet || this.value === null || this.value === "")
    #       "required"
    autoform:
      type: "select"
      options: commonSearchOptionsSelect
      afFormGroup:
        'formgroup-class': 'col-sm-12'
  field1:
    type: [String]
    label: 'Rows'
    optional: true
    # custom: () ->
    #   shouldBeRequired = this.field('commonOptions').value == [] || this.field('field2').value == []
    #   if shouldBeRequired
    #     if (!this.isSet || this.value === null || this.value === "")
    #       "required"
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
    # custom: () ->
    #   shouldBeRequired = this.field('commonOptions').value == [] || this.field('field1').value == []
    #   if shouldBeRequired
    #     if (!this.isSet || this.value === null || this.value === "")
    #       "required"
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
