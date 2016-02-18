Router.route '/', {
  name: 'home'
  template: 'matrix'
}

Router.route '/license/:_id', {
    name: 'insert'
    template: 'MatrixForm'
    data: () -> LicenseMatrix.findOne({ _id: this.params._id })
}

Router.route '/showlicense/:_id', {
    name: 'license'
    template: 'spdxLicense'
    license: () -> LicenseMatrix.findOne({ _id: this.params._id })
}
Router.configure { layoutTemplate: 'home' }
