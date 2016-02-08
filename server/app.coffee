#server only code

@spdxLicenseIds = Meteor.npmRequire('spdx-license-ids')

Meteor.startup ->
  console.log "inside startup"
  if BooksIds.find().count() == 0
    BooksIds.insert {data: 'title', title: 'Title'}
    idx = 0
    for c in spdxLicenseIds[0..10]
      BooksIds.insert { data : "lid_" + idx++, title : c}
    console.log BooksIds.find().fetch()

  if Books.find().count() == 0



    licence = {}
    idx = 0
    for c in spdxLicenseIds[0..10]
      licence["lid_" + idx++] = c

    for cext in spdxLicenseIds[0..10]
      licence['title'] = cext
      console.log licence
      Books.insert licence

console.log "after startup"
