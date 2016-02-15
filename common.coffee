console.log "common"
@Books = new Mongo.Collection 'players'

Books.allow {
  insert: () -> true
  update: () -> true
  remove: () -> true
}

TabularTables = {}

Meteor.isClient and Template.registerHelper('TabularTables', TabularTables)

console.log "publishing"

idx = 0
columns = [ { data: "title" , title : "Title"} ]
for licence in spdxLicenseIds
  col = "lid_" + idx++
  v = do (col,licence) -> {
      searchable: false
      data : col
      title : licence
      tmpl: Meteor.isClient and Template.LicenceSwitch
      tmplContext: Meteor.isClient and Tracker.nonreactive () -> (rowData) -> {
        data: rowData
        col : col
        selected: rowData[col]
      }
    }
  columns.push v

TabularTables.Books = new (Tabular.Table) (
    name: 'BookList'
    collection: Books
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

Meteor.isClient and console.log Books.find().count()
Meteor.isClient and console.log "here " + Books.find().count()
