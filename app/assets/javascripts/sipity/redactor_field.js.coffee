class RedactorTextInput
  constructor: (@fieldElement) ->
    if @fieldElement.length > 0
      @setupField()

  setupField: ->
    @fieldElement.redactor({
      buttonSource: true
      focus: true
      buttons: ['bold', 'italic']
    })

class RedactorTextArea
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

  setupRedactorTextInputs = () ->
    field = $(".redactor-input")
    if field.size() > 0
      new RedactorTextInput(field)

  setupRedactorTextAreas = () ->
    field = $(".redactor-area")
    if field.size() > 0
      new RedactorTextArea(field)

  ready = ->
    setupRedactorTextInputs()
    setupRedactorTextAreas()

  $(document).ready(ready)
  $(document).on('page:load', ready)
