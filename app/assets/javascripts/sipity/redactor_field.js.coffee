class RedactorField
  constructor: (@fieldElement) ->
    if @fieldElement.length > 0
      @setupField()

  setupField: ->
    @fieldElement.redactor({
      buttonSource: true
      focus: true
      formatting: ['p', 'blockquote', 'h3', 'h4', 'h5']
    })


jQuery ($) ->

  setupRedactor = () ->
    field = $(".sipity_redactor")
    if field.size() > 0
      new RedactorField(field)

  ready = ->
    setupRedactor()

  $(document).ready(ready)
  $(document).on('page:load', ready)
