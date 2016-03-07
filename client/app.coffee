console.log "on client"

# AutoForm.debug()

Comments.ui.config
  template: 'bootstrap'
  markdown: true

Comments.config
  beforeInsert: (e) ->
    v = [e.target['analysis.compatibility'].value]
    { "analysis" : { compatibility: v } }

Template.registerHelper "debug", (optionalValue) ->
    console.log("Current Context")
    console.log("====================")
    console.log(this)

    if optionalValue
      console.log("Value")
      console.log("====================")
      console.log(optionalValue)

AutoForm.hooks
  MatrixForm:
    onSuccess: (formType, result) ->
      doc = this.currentDoc
      subdoc = this.insertDoc
      console.log doc
      console.log subdoc
      console.log this
      d =
        licence1: SpdxLicense.findOne(doc.spdxid1).spdxid
        licence2: SpdxLicense.findOne(doc.spdxid2).spdxid
        submittedBy: subdoc.submittedBy
      m = ModerationTable.findOne(d)
      if m
        ModerationTable.update(m, {"$set": { compatibility : subdoc.compatibility}})
      else
        d['docid'] = doc._id
        d['compatibility'] = subdoc.compatibility
        d['submittedBy'] = subdoc.submittedBy
        ModerationTable.insert d

Template.registerHelper "getRealName", (userId) ->
  Meteor.users.findOne(userId).profile.firstName

Template.registerHelper "boolString", (b) ->
  String(b)

Template.registerHelper "daysAgo", (d) ->
  "10 days ago"

Template.registerHelper "uniqueID", (t) ->
  t + this._id

Template.quickForm_MatrixForm.helpers
  "exampleDoc": () ->
    LicenseMatrix.findOne(this.atts.doc._id)
  "notOwner" : (doc) ->
    (doc.submittedBy != undefined) and (doc.submittedBy != this.usersId)

Accounts.ui.config
  passwordSignupFields: 'EMAIL_ONLY'
  requestPermissions: {}
  extraSignupFields: [
    {
      fieldName: 'firstName'
      fieldLabel: 'First name'
      inputType: 'text'
      visible: true
      validate: (value, errorFunction) ->
        if !value
          errorFunction 'Please write your first name'
          false
        else
          true
    }
    {
      fieldName: 'lastName'
      fieldLabel: 'Last name'
      inputType: 'text'
      visible: true
    }
    {
      fieldName: 'terms'
      fieldLabel: 'I accept the terms and conditions'
      inputType: 'checkbox'
      visible: true
      saveToProfile: false
      validate: (value, errorFunction) ->
        if value
          true
        else
          errorFunction 'You must accept the terms and conditions.'
          false

    }
  ]

Template.spdxLicenseView.helpers
  "getLicenseData": (spdxid) ->
    SpdxLicense.findOne(spdxid)

Template._loginButtonsAdditionalLoggedInDropdownActions.events
  'click #login-buttons-edit-profile': (event) ->
    Router.go 'profile'

Template.LicenseCategory.onCreated () ->
  this.isEditing = false
  this.isEditingDep = new Deps.Dependency()

Template.LicenseCategory.helpers
  'editing': () ->
    self = Template.instance()
    self.isEditingDep.depend()
    self.isEditing

Template.LicenseCategory.events
  'click .data-category': (e, t) ->
    t.isEditing = false
    t.isEditingDep.changed()
  'click': (e, t) ->
    t.isEditing = true;
    t.isEditingDep.changed()

Template.LicenseComments.helpers
  CommentsCollection: Comments.getCollection()
  formclass: (reply) -> if reply then "reply-form" else "comment-form"
  textareaclass: (reply) -> "form-control " + (if reply then "create-reply" else "create-comment")
