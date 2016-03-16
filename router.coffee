Router.route '/', {
  name: 'home'
  template: 'SelectLicense'
}

Router.route '/moderation', {
  name: 'moderation'
  template: 'ModerationTable'
  onBeforeAction: () ->
    unless Meteor.user() or Roles.userIsInRole(userId, [ 'editor' ])
      this.render('home')
    else
      this.next();
}

Router.route '/licenses', {
  name: 'licenses'
  template: 'LicensesTable'
}

Router.route '/download', {
  name: 'download'
  template: 'DownloadData'
}

Router.route '/download/spdx',
  where: 'server'
  name: 'download-spdx'
  action: () ->
    # only if tags, category, limitation, permission, conditions exists.
    data = JSON.stringify(SpdxLicense.find(
      {$or: [
        {tags: {$exists: true, $ne: []}},
        {category: {$exists: true, $ne: []}},
        {permission: {$exists: true, $ne: []}},
        {conditions: {$exists: true, $ne: []}},
        {limitation: {$exists: true, $ne: []}},
      ]}).fetch())
    filename = 'spdx-annotation.json'
    @response.setHeader("Content-Type", "application/json")
    @response.setHeader("Content-Disposition", 'attachment; filename=' + filename)
    @response.setHeader("Content-Length", data.size)
    @response.end data
    this.render('download')

Router.route '/download/matrix',
  where: 'server'
  name: 'download-matrix'
  action: () ->
    data = JSON.stringify(LicenseMatrix.find().fetch())
    filename = 'spdx-matrix.json'
    @response.setHeader("Content-Type", "application/json")
    @response.setHeader("Content-Disposition", 'attachment; filename=' + filename)
    @response.setHeader("Content-Length", data.size)
    @response.end data
    return

Router.route '/admin', {
  name: 'admin'
  template: 'UserTable'
  onBeforeAction: () ->
    unless Meteor.user() or Roles.userIsInRole(userId, [ 'admin' ])
      this.render('home')
    else
      this.next();
}

Router.route '/profile', {
  name: 'profile'
  template: 'UserProfile'
  data: () -> Meteor.user()
  onBeforeAction: () ->
    unless Meteor.user()
      this.render('home')
    else
      this.next();
}

Router.configure { layoutTemplate: 'home' }
