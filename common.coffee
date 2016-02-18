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
        { id: if row then LicenseMatrix.findOne(row._id) else null }

TabularTables.LicenseMatrix = new (Tabular.Table) (
    name: 'Licence List'
    collection: LicenseMatrixTable
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
