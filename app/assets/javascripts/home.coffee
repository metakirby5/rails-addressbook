# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

(($) ->

  EDITABLE_TEXT = 'editable-text'
  EDITABLE_TOGGLE = 'editable-toggle'
  EDITING = 'editable-text-editing'
  TEXT_INPUT = (val) ->
    "<input type='text' value='#{val}' />"
  HEART_TOGGLE = (turnon) ->
    "<span class='glyphicon glyphicon-heart#{if turnon then '' else 'empty'}'>"

  classify = (c) ->
    '.' + c

  editoff = (elt) ->
    elt.removeClass(EDITING)
    elt.data('editing', false)

  # http://mrbool.com/how-to-create-an-editable-html-table-with-jquery/27425
  editText = ->
    elt = $(this)
    if not elt.data('editing')
      elt.data('editing', true)
      orig = elt.text()

      elt.addClass('editable-text-editing')
      elt.html(TEXT_INPUT(orig))

      textbox = elt.children().first()
      textbox.focus()

      textbox.keypress((e) ->
        if e.which == 13
          elt.text(textbox.val())
          editoff(elt)
      )

      textbox.blur(->
        elt.text(orig)
        editoff(elt)
      )

  editToggle = ->
    elt = $(this)

  $(->
    $(classify(EDITABLE_TEXT)).click editText
    $(classify(EDITABLE_TOGGLE)).click editToggle
  )
)(window.jQuery)
