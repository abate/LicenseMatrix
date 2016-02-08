@Books = new Mongo.Collection 'players'
@BooksIds = new Mongo.Collection 'playersIds'

TabularTables = {}

Meteor.isClient and Template.registerHelper('TabularTables', TabularTables)

columns = []
for a in BooksIds.find().fetch()
  console.log a
  columns.push { data : a.data, title : a.title }

console.log "AAA"
console.log columns
console.log Books.find().fetch()
console.log BooksIds.find().fetch()
console.log "BBB
"
TabularTables.Books = new (Tabular.Table)(
  name: 'BookList'
  collection: Books
  columns: columns
)
console.log "after Tabular"
