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
  'click .data-category': (e,t) ->
    console.log "data-category"
    t.isEditingCat = true
    t.isEditingCatDep.changed()
  'blur .data-category-form': (e, t) ->
    console.log "data-category-form"
    t.isEditingCat = false
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

Template.SpdxLicenseCompatibilityTable.events 'click .reactive-table tbody tr': (event) ->
  event.preventDefault()
  if event.target.className == 'delete fa fa-trash'
    SpdxLicenseCompatibility.remove(this._id)

isAuthorized = () ->
  userId=Meteor.userId()
  !(Roles.userIsInRole(userId, [ 'editor','admin' ]))

Template.SpdxLicenseCompatibilityTable.helpers
  'SpdxLicenseCompatibilityTableSettings': (spdxid1) ->
    collection: SpdxLicenseCompatibility.find({spdxid1: spdxid1})
    showFilter: false
    showNavigation: "auto"
    rowsPerPage: 20
    # noDataTmpl: SpdxLicenseCompatibilityTableEmpty
    fields: [
      {key: "spdxid1", label: "License", sortable: false, fn: (spdxid1) -> SpdxLicense.findOne(spdxid1).spdxid},
      {key: "orlater1", label: "", sortable: false, fn: (orlater) -> if orlater == true then "+" else ""},
      {key: "exceptions", label: "Exceptions", sortable: false},
      {key: "compatibility", label: "Compatibility", sortable: false, tmpl: Template.SpdxLicenseCompatibilityField },
      {key: "spdxid2", label: "With", sortable: false, fn: (spdxid2) -> SpdxLicense.findOne(spdxid2).spdxid},
      {key: "orlater2", label: "", sortable: false, fn: (orlater) -> if orlater == true then "+" else ""},
      {key: "relicenseto", label: "Re-License To", sortable: false, fn: (relicenseto) -> if relicenseto then SpdxLicense.findOne(relicenseto).spdxid},
      {key: "orlater3", label: "", sortable: false, fn: (orlater) -> if orlater == true then "+" else ""},
      {key: "delete", label: "", sortable: false, tmpl: Template.SpdxLicenseCompatibilityDelete, hidden: () -> isAuthorized() },
      {key: "update", label: "", sortable: false, tmpl: Template.SpdxLicenseCompatibilityEdit, hidden: () -> isAuthorized() }
    ]

Template.LicensesTable.helpers
  'LicensesTableSettings': () ->
    collection: SpdxLicense
    fields: [
      {key: "url", label: "Name", tmpl: Template.LicenseUrl },
      {key: "categories", label:"Category", tmpl: Template.LicenseCategory },
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
      { key: 'actions', label: 'Actions', tmpl: Template.userActions }
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
