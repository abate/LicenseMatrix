console.log "on client"

# AutoForm.debug()

Comments.ui.config
  template: 'bootstrap'
  markdown: true

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

# Comments._collection.after.insert (userId, comment) ->
#   console.log userId
#   console.log comment
#   console.log this
#   console.log "Comment added"

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
