console.log "common"
@Books = new Mongo.Collection 'players'

TabularTables = {}

Meteor.isClient and Template.registerHelper('TabularTables', TabularTables)

console.log "publishing"

idx = 0
columns = [ { data: "title" , title : "Title"} ]
for c in spdxLicenseIds
  columns.push { data : "lid_" + idx++, title : c}

TabularTables.Books = new (Tabular.Table) (
    name: 'BookList'
    collection: Books
    columns: columns
    scrollY: 400
    scrollX: true
    scrollCollapse: true
    fixedColumns: true
    # paging: false
    responsive: true
    autoWidth: false
  )

Meteor.isClient and console.log Books.find().count()
Meteor.isClient and console.log "here " + Books.find().count()
