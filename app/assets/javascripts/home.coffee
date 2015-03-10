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
    "<span class='glyphicon glyphicon-heart#{if turnon then '' else '-empty'}'>"

  # make string into css class
  classify = (c) ->
    '.' + c

  # get dom element data-id
  getId = (elt) ->
    elt.data 'id'

  # get whether or not friends with current tr
  friendsWith = (elt) ->
    elt.data 'friended'

  # friend a tr
  friend = (elt) ->
    elt.data 'friended', 1

  # unfriend a tr
  unfriend = (elt) ->
    elt.data 'friended', 0

  # get contact info for current tr
  contactInfoFor = (elt) ->
    {
      name: do $(elt.children('.name')[0]).text
      email: do $(elt.children('.email')[0]).text
      phone: do $(elt.children('.phone')[0]).text
    }

  # turn edit mode on
  editon = (elt) ->
    elt.data 'editing', true
    elt.addClass EDITING
    do elt.text

  # switch textbox back to table cell
  editoff = (elt, text) ->
    elt.data 'editing', false
    elt.removeClass EDITING
    elt.text text

  # callback to edit table cell
  # http://mrbool.com/how-to-create-an-editable-html-table-with-jquery/27425
  editText = ->
    elt = $(this)
    if not elt.data 'editing'
      # turn on editing
      orig = editon elt

      # make into textbox
      elt.html TEXT_INPUT(orig)
      textbox = do elt.children().first
      do textbox.focus

      textbox.keypress (e) ->
        # on enter key
        if e.which == 13
          # clear alerts
          $(document).trigger 'clear-alerts'

          # apply text changes
          newtext = do textbox.val
          # strip phone non-numbers
          if elt.hasClass 'phone'
            newtext = newtext.replace /\D/g,''
          editoff elt, newtext

          # begin ajax
          row = do elt.parent
          $.ajax {
            method: 'PUT',
            url: "/contacts/#{getId(row)}",
            data: contactInfoFor row
            error: (x) ->
              # reset text
              elt.text orig

              # display errors
              errs = $.parseJSON(x.responseText).errors
              $(document).trigger 'add-alerts', ({
                message: err,
                priority: 'warning'
              } for err in errs)
          }

      # cancel on defocus
      textbox.blur ->
        editoff elt, orig

  # callback to friend/unfriend
  editToggle = ->
    elt = $(this)
    row = do elt.parent

    console.log row.data('friended')
    if friendsWith row
      unfriend row
      elt.html HEART_TOGGLE false
    else
      friend row
      elt.html HEART_TOGGLE true

  $ ->
    # Set up error box
    $('#alerts').bsAlerts {
      titles: {
        warning: '<em>Error!</em>',
      },
      fade: 6000
    }

    $(classify EDITABLE_TEXT).click editText
    $(classify EDITABLE_TOGGLE).click editToggle

)(window.jQuery, window._)
