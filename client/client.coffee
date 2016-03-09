console.log "on client"

# AutoForm.debug()

Comments.ui.config
  template: 'bootstrap'
  markdown: true

# Comments.config
#   beforeInsert: (e) ->
#     console.log "AAAAAAA"
#     console.log e.target
#     if 'analysis.compatibility' in e.target
#       v = [e.target['analysis.compatibility'].value]
#       { "analysis" : { compatibility: v } }
#     else {}
#   onSuccess: (id) ->
#     AutoForm.resetForm(id)

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

# Global helpers
Template.registerHelper "boolString", (b) ->
  String(b)

Template.registerHelper "daysAgo", (d) ->
  "10 days ago"

Template.registerHelper "uniqueID", (t) ->
  t + this._id

Template.registerHelper "getRealName", (userId) ->
  Meteor.users.findOne(userId).profile.firstName

Template.registerHelper "debug", (optionalValue) ->
    console.log("Current Context")
    console.log("====================")
    console.log(this)

    if optionalValue
      console.log("Value")
      console.log("====================")
      console.log(optionalValue)

CommentsHelpers =
  "hascomments": (referenceId) ->
    if referenceId
      Comments.getCollection().find({ referenceId: referenceId }).count() != 0
    else false
  "countcomments": (referenceId) ->
    if referenceId
      Comments.getCollection().find({ referenceId: referenceId }).count()
    else false

Template.LicenseSwitch.helpers(CommentsHelpers)
Template.quickForm_MatrixForm.helpers(CommentsHelpers)
Template.SelectLicenseCell.helpers(CommentsHelpers)

Template.quickForm_MatrixForm.helpers
  "exampleDoc": () ->
    LicenseMatrix.findOne(this.atts.doc._id)
  "notOwner" : (doc) ->
    (doc.submittedBy != undefined) and (doc.submittedBy != this.usersId)

Template.spdxLicenseView.helpers
  "getLicenseData": (spdxid) ->
    SpdxLicense.findOne(spdxid)

Template._loginButtonsAdditionalLoggedInDropdownActions.events
  'click #login-buttons-edit-profile': (event) ->
    Router.go 'profile'
  'click #login-buttons-admin': (event) ->
    Router.go 'admin'
  'click #login-buttons-moderation': (event) ->
    Router.go 'moderation'

Template.LicenseCategory.onCreated () ->
  this.isEditingCat = false
  this.isEditingCatDep = new Deps.Dependency()

Template.LicenseCategory.helpers
  'editing': () ->
    self = Template.instance()
    self.isEditingCatDep.depend()
    self.isEditingCat

Template.LicenseCategory.events
  'click .data-category': (e, t) ->
    console.log "data-category click category"
    t.isEditingCat = false
    t.isEditingCatDep.changed()
  'click': (e, t) ->
    console.log "LicensesTable click category"
    t.isEditingCat = true
    t.isEditingCatDep.changed()

Template.LicenseTags.onCreated () ->
  this.isEditingTag = false
  this.isEditingTagDep = new Deps.Dependency()

Template.LicenseTags.helpers
  'editing': () ->
    self = Template.instance()
    self.isEditingTagDep.depend()
    self.isEditingTag

Template.LicenseTags.events
  'click .data-category': (e, t) ->
    # console.log "data-category click tags"
    t.isEditingTag = false
    t.isEditingTagDep.changed()
  'click': (e, t) ->
    # console.log "LicensesTable click tags"
    t.isEditingTag = true
    t.isEditingTagDep.changed()

Template.LicenseComments.helpers
  CommentsCollection: Comments.getCollection()
  formclass: (reply) -> if reply then "reply-form" else "comment-form"
  textareaclass: (reply) -> "form-control " + (if reply then "create-reply" else "create-comment")

Template.SelectLicense.helpers
  'selectLicenseSchema': () -> Schemas.SpdxLicenseSearch
  'tableSettings': () -> Template.instance().tableSettings
  'getSettings': (dict) ->
    if dict
      t = dict.get('tableSettings')
      if t
        for e in t.fields
          if e.key == 'rowid'
            e['tmpl'] = Template.SelectLicenseName
          else
            e['tmpl'] = Template.SelectLicenseCell
      t
    else { fields: ["License"], collection: [] }

Template.SelectLicenseCell.helpers
  'getCell' : () ->
    key = Template.parentData(1).key
    this[key]

Template.SelectLicense.events
  'click #reset-select': (event) ->
    console.log "reset does not work !"
    # $("select2-container").select2("val", "")
    # $('#LicenseSearchForm')[0].reset();

Template.SelectLicense.onCreated () ->
  console.log "onCreated"
  this.tableSettings = new ReactiveDict()

Template.LicensesTable.helpers
  'LicensesTableSettings': () ->
    collection: SpdxLicense
    fields: [
      {key: "spdxid", label:"SPDX-ID"},
      {key: "url", label: "Name", tmpl: Template.LicenseUrl },
      {key: "osiApproved", label:"OSI", tmpl: Template.LicenseOSI },
      {key: "category", label:"Category", tmpl: Template.LicenseCategory },
      {key: "tags", label:"Tags", tmpl: Template.LicenseTags },
    ]

Template.UserTable.helpers
  'UserTableSettings': () ->
    collection: Meteor.users
    fields: [
      { key: 'profile.firstName', label: 'firstName'},
      { key: 'profile.lastName', label: 'lastName' }
      { key: 'roles', label: 'Roles' }
      { key: 'createdAt', label: 'CreatedAt' },
      { key: 'actions', label: 'Actions', tmpl: Template.UserActions }
    ]

Template.ModerationTable.helpers
  'ModerationTableSettings': () ->
    collection: ModerationTable
    # selector: (userId) ->
    #   if Roles.userIsInRole(userId, [ 'editor','admin' ]) then {}
    #   else { submittedBy: userId }
    # extraFields: ['docid','submittedBy']
    fields: [
      {key: 'licence1', label: 'Licence'},
      {key: 'licence2', label: 'Licence'},
      {key: 'username()', label: 'Submitted By'},
      {key: 'compatibility', label: 'Compatibility'},
      {key: 'actions', label: 'Actions', tmpl: Template.ModerationActions }
     ]

AutoForm.hooks
  LicenseCommentsForm:
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
  LicenseSearchForm:
    # onSuccess: (formType,result) ->
    #   AutoForm.resetForm(this.formId)
    onSubmit: (insertDoc, updateDoc, currentDoc) ->
      this.event.preventDefault()
      AutoForm.getValidationContext(this.formId).resetValidation()
      matchsearch = (s) ->
        if m = s.match(/tag:(.*)/)
          {tags: m[1]}
        else if m = s.match(/cat:(.*)/)
          {category: m[1]}
        else if m = s.match(/spdx:(.*)/)
          {_id : m[1]}
        else if m = s.match(/osi:(.*)/)
          {osiApproved: m[1]}
      h = insertDoc.field1.map matchsearch
      v = insertDoc.field2.map matchsearch
      columns = SpdxLicense.find({$or: v}).fetch()
      rows = SpdxLicense.find({$or: h}).fetch()
      localtemplate = this.template
      do (localtemplate) ->
        Meteor.subscribe "Licensematrix", {}, () ->
          #onReady callback
          columnsnames = []
          columnsnames.push
            key: 'rowid'
            label: 'License'
          for i in columns
            columnsnames.push
              key: i._id
              label: i.spdxid
          collectionArray = []
          for i in rows
            tmp = {rowid: i.spdxid}
            for j in columns
              [x,y] = orderIDX(i,j)
              lm = LicenseMatrix.findOne({spdxid1: x, spdxid2: y})
              if lm
                tmp[j._id] = lm
              else
                id = LicenseMatrix.insert ({spdxid1: x, spdxid2: y, analysis: []})
                tmp[j._id] = LicenseMatrix.findOne(id)
            collectionArray.push tmp
          settings =
            collection: collectionArray
            fields: columnsnames
          localtemplate.data.tableSettings.set('tableSettings', settings)
      this.done()
      false
