console.log "common"
TabularTables = {}

Meteor.isClient and Template.registerHelper('TabularTables', TabularTables)

columns = [ { data: "title" , title : "Title" } ]
idx = 0
for License in spdxLicenseIds[0..4]
  col = "lid_" + idx++
  do(License,col) ->
    columns.push
      searchable: false
      data: col
      title: License
      tmpl: Meteor.isClient and Template.LicenseSwitch
      tmplContext: (rowdata) ->
        row = rowdata[col]
        { doc: if row then LicenseMatrix.findOne(row) else null }

TabularTables.LicenseMatrix = new Tabular.Table (
  name: 'Licence List'
  collection: LicenseMatrixTable
  selector: (userId) ->
    {$or: [
      {submittedBy : userId},
      {submittedBy: {"$eq" : undefined}},
      {verified: {"$eq": true}}
      ]}
  columns: columns
  scrollY: 400
  scrollX: true
  scrollCollapse: true
  fixedColumns: true
  fixedHeader: true
  # responsive: true
  # autoWidth: false
  bSort: false
)

TabularTables.Moderation = new Tabular.Table (
  name: 'Moderation'
  collection: ModerationTable
  selector: (userId) ->
    if Roles.userIsInRole(userId, [ 'admin' ]) then {}
    else { user: userId }
  extraFields: ['docid','submittedBy']
  columns: [
    {data: 'licence1', title: 'Licence'},
    {data: 'licence2', title: 'Licence'},
    {data: 'username', title: 'Submitted By'},
    {data: 'compatibility', title: 'Compatibility'},
    { data: 'actions',
    title: 'Actions',
    tmpl: Meteor.isClient and Template.ModerationActions,
    tmplContext: (rowdata) ->
      { docid: rowdata.docid, rowid: rowdata._id }
    }
   ]
)

TabularTables.UsersTable = new Tabular.Table (
  name: 'Users'
  collection: Meteor.users
  autoWidth: true
  columns: [
    { data: 'profile.firstName', title: 'firstName'},
    { data: 'profile.lastName', title: 'lastName' }
    { data: 'roles', title: 'Roles' }
    { data: 'createdAt', title: 'CreatedAt' },
    { data: 'actions',
    title: 'Actions',
    tmpl: Meteor.isClient and Template.UserActions,
    tmplContext: (rowdata) ->
      { doc: Meteor.users.findOne(rowdata._id) }
    }
  ]
)
