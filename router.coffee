Router.route '/', {
  name: 'home'
  template: 'matrix'
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
  data: () ->
    Meteor.userId()
  onBeforeAction: () ->
    unless Meteor.user()
      this.render('home')
    else
      this.next();
}

Router.configure { layoutTemplate: 'home' }
