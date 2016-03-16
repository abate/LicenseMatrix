Template.LicenseTags.onCreated () ->
  this.isEditingTag = false
  this.isEditingTagDep = new Deps.Dependency()

# Template.LicenseTags.onRendered () ->
#   console.log ["after rendered",$('.data-category-form'),this]
#   $('.data-category-form').first().focus()

Template.LicenseTags.helpers
  'editing': () ->
    self = Template.instance()
    self.isEditingTagDep.depend()
    self.isEditingTag

Template.LicenseTags.events
  'click .data-category': (e, t) ->
    console.log ["data-category click tags",this,t,$(this).find('.data-category-form')]
    t.isEditingTag = true
    t.isEditingTagDep.changed()
    # $(this).find('.data-category-form').first().focus()
  'blur': (e, t) ->
    console.log "LicensesTable form click tags"
    t.isEditingTag = false
    t.isEditingTagDep.changed()

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
    t.isEditingCat = true
    t.isEditingCatDep.changed()
  'blur': (e, t) ->
    console.log "LicensesTable form click category"
    t.isEditingTag = false
    t.isEditingCatDep.changed()

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
      console.log t
      t
    else { fields: ["License"], collection: [] }

Template.SelectLicenseCell.helpers
  'getCell' : () ->
    key = Template.parentData(1).key
    this[key]

Template.SelectLicense.events
  'click #reset-select': (event) ->
    $('select').each () ->
      $(this).context.selectize.clear()
    AutoForm.getValidationContext(this.formId).resetValidation()
    Template.instance().tableSettings.set('tableSettings', { fields: ["License"], collection: [] })

Template.SelectLicense.onCreated () ->
  console.log "onCreated"
  this.tableSettings = new ReactiveDict()

Template.LicensesTable.helpers
  'LicensesTableSettings': () ->
    collection: SpdxLicense
    fields: [
      # {key: "spdxid", label:"SPDX-ID"},
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
