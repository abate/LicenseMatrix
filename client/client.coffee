console.log "on client"

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

Template.LicenseComments.helpers
  CommentsCollection: Comments.getCollection()
  formclass: (reply) -> if reply then "reply-form" else "comment-form"
  textareaclass: (reply) -> "form-control " + (if reply then "create-reply" else "create-comment")

Template.SelectLicense.events
  'click #AdvancedSearch': () ->
    if Session.get('AdvancedSearch') == false
      Session.set('AdvancedSearch',true)
    else
      Session.set('AdvancedSearch',false)

Template.SelectLicense.helpers
  'AdvancedSearch': () ->
    Session.get('AdvancedSearch')

Template.spdxLicenseForm.helpers
  'seedCompatilityForm': (spdxid) -> { spdxid1: spdxid }
  'emptySpdxLicenseCompatibility': (spdxid) ->
    SpdxLicenseCompatibility.find({ spdxid1: spdxid }).count() == 0

Template.quickForm_MatrixForm.helpers
  'emptySpdxLicenseCompatibility': (spdxid) ->
    SpdxLicenseCompatibility.find({ spdxid1: spdxid }).count() == 0

AutoForm.hooks
  spdxLicenseForm:
    onSubmit: (insertDoc, updateDoc, currentDoc) ->
      console.log insertDoc
      console.log updateDoc
      console.log "spdxLicenseForm"
  spdxLicenseCompatibilityForm:
    onSuccess: (formType, result) ->
      # this.event.preventDefault()
      doc = this.currentDoc
      subdoc = this.insertDoc
      console.log doc
      console.log subdoc
      console.log result
      console.log  SpdxLicenseCompatibility.findOne(result)
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
      if insertDoc.commonOptions
        doc = commonSearchOptions[insertDoc.commonOptions]
      else
        doc = insertDoc
      matchsearch = (s) ->
        if m = s.match(/tag:(.*)/)
          {tags: m[1]}
        else if m = s.match(/cat:(.*)/)
          {categories: m[1]}
        else if m = s.match(/cond:(.*)/)
          {conditions: m[1]}
        else if m = s.match(/lim:(.*)/)
          {limitations: m[1]}
        else if m = s.match(/perm:(.*)/)
          {permissions: m[1]}
        else if m = s.match(/spdx:(.*)/)
          {_id : m[1]}
      if doc.field1 and doc.field2
        h = doc.field1.map matchsearch
        v = doc.field2.map matchsearch
        columns = SpdxLicense.find({$or: v}).fetch()
        rows = SpdxLicense.find({$or: h}).fetch()
        localtemplate = this.template
        do (localtemplate) ->
          Meteor.subscribe "Spdxlicensecompatibility", {}, () ->
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
            cache = {}
            for i in rows
              tmp = {rowid: i.spdxid}
              for j in columns
                [x,y] = [i._id,j._id]
                if cache[x+y]
                  tmp[j._id] = null
                else if x == y
                  tmp[j._id] = null
                else
                  cache[x+y] = true
                  lm = SpdxLicenseCompatibility.findOne({spdxid1: x, spdxid2: y})
                  if lm
                    tmp[j._id] = lm
                  else
                    do (tmp,j) ->
                      Meteor.call('addLicense', x, y, (error,id) ->
                        tmp[j._id] = SpdxLicenseCompatibility.findOne(id)
                      )
              collectionArray.push tmp
            settings =
              collection: collectionArray
              fields: columnsnames
            localtemplate.data.tableSettings.set('tableSettings', settings)
        # $('select').each () ->
        #   console.log $(this)
        #   $(this).context.selectize.clear()
      AutoForm.getValidationContext(this.formId).resetValidation()
      AutoForm.resetForm(this.formId)
      this.done()
      false
