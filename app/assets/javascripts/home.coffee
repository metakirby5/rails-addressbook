# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require jquery.bsAlerts.min
#= require lodash.min

(($, _) ->

  EDITABLE_TEXT = 'editable-text'
  EDITABLE_TOGGLE = 'editable-toggle'
  EDITING = 'editable-text-editing'
  TEXT_INPUT = (val) ->
    "<input type='text' value='#{val}' />"
  HEART_TOGGLE = (turnon) ->
    "<span class='glyphicon glyphicon-heart#{if turnon then '' else 'empty'}'>"

  classify = (c) ->
    '.' + c

  getId = (elt) ->
    elt.data('id')

  getFriendship = (elt) ->
    true #TODO

  getContactInfo = (elt) ->
    {
      name: $(elt.children('.name')[0]).text()
      email: $(elt.children('.email')[0]).text()
      phone: $(elt.children('.phone')[0]).text()
    }

  editoff = (elt) ->
    elt.removeClass(EDITING)
    elt.data('editing', false)

  # http://mrbool.com/how-to-create-an-editable-html-table-with-jquery/27425
  editText = ->
    elt = $(this)
    if not elt.data('editing')
      elt.data('editing', true)
      orig = elt.text()

      elt.addClass(EDITING)
      elt.html(TEXT_INPUT(orig))

      textbox = elt.children().first()
      textbox.focus()

      textbox.keypress((e) ->
        if e.which == 13
          newtext = textbox.val()
          # strip phone non-numbers
          if elt.hasClass('phone')
            newtext = newtext.replace(/\D/g,'')
          elt.text(newtext)
          editoff(elt)

          # begin ajax
          row = elt.parent()
          $.ajax({
            method: 'PUT',
            url: "/contacts/#{getId(row)}",
            data: getContactInfo(row)
            error: (x) ->
              elt.text(orig)
              $(document).trigger('clear-alerts')
              errs = $.parseJSON(x.responseText).errors
              $(document).trigger('add-alerts', ({
                message: err,
                priority: 'warning'
              } for err in errs));
          })
      )

      textbox.blur(->
        elt.text(orig)
        editoff(elt)
      )

  editToggle = ->
    elt = $(this)

  $(->
    # Set up error box
    # %div{data: {alerts: 'alerts', titles: '{"error": "<em>Error!</em>"}', ids: 'ajax-errors', fade: '6000'}}}
    $('#alerts').bsAlerts({
      titles: {
        warning: '<em>Error!</em>',
      },
      fade: 6000
    })

    $(classify(EDITABLE_TEXT)).click(editText)
    $(classify(EDITABLE_TOGGLE)).click(editToggle)
  )
)(window.jQuery, window._)
