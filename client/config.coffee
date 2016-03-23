console.log "client config"

# AutoForm.debug()

Comments.ui.config
  template: 'bootstrap'
  markdown: true

Accounts.ui.config
  passwordSignupFields: 'EMAIL_ONLY'
  requestPermissions: {}
  extraSignupFields: [
    {
      fieldName: 'firstName'
      fieldLabel: 'First name'
      inputType: 'text'
      visible: true
      validate: (value, errorFunction) ->
        if !value
          errorFunction 'Please write your first name'
          false
        else
          true
    }
    {
      fieldName: 'lastName'
      fieldLabel: 'Last name'
      inputType: 'text'
      visible: true
    }
    {
      fieldName: 'terms'
      fieldLabel: 'I accept the terms and conditions'
      inputType: 'checkbox'
      visible: true
      saveToProfile: false
      validate: (value, errorFunction) ->
        if value
          true
        else
          errorFunction 'You must accept the terms and conditions.'
          false
    }
  ]
