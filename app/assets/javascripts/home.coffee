# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require jquery.bsAlerts.min
#= require lodash.min

(($, _) ->

  EDITABLE_TEXT = 'editable-text'
  EDITABLE_HEART = 'editable-heart'
  EDITABLE_TRASH = 'editable-trash'
  EDITING = 'editable-text-editing'
  TEXT_INPUT = (val) ->
    "<input type='text' value='#{val}' />"
  HEART_TOGGLE = (turnon) ->
    "<span class='glyphicon glyphicon-heart#{if turnon then '' else '-empty'}'>"

  # make string into css class
  classify = (c) ->
    '.' + c

  # get tr element data-id
  idOf = (row) ->
    row.data 'id'

  # get whether or not friends with current tr
  friendsWith = (row) ->
    row.data 'friended'

  # friend a tr
  friend = (row, heart) ->
    row.data 'friended', 1
    heart.html HEART_TOGGLE(true)

  # unfriend a tr
  unfriend = (row, heart) ->
    row.data 'friended', 0
    heart.html HEART_TOGGLE(false)

  # get contact info for current tr
  contactInfoFor = (row) ->
    {
      name: do $(row.children('.name')[0]).text
      email: do $(row.children('.email')[0]).text
      phone: do $(row.children('.phone')[0]).text
    }

  # turn edit mode on
  editOn = (cell) ->
    cell.data 'editing', true
    cell.addClass EDITING
    do cell.text

  # switch textbox back to table cell
  editOff = (cell, text) ->
    cell.data 'editing', false
    cell.removeClass EDITING
    cell.text text

  # add errors to alert
  addErrors = (errs) ->
    $(document).trigger 'add-alerts', ({
    message: err,
    priority: 'warning'
    } for err in errs)

  # callback to edit table cell
  # http://mrbool.com/how-to-create-an-editable-html-table-with-jquery/27425
  editText = ->
    elt = $(this)
    if not elt.data 'editing'
      # turn on editing
      orig = editOn elt

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
          editOff elt, newtext

          # begin ajax
          row = do elt.parent
          $.ajax {
            method: 'PUT',
            url: "/contacts/#{idOf(row)}",
            data: contactInfoFor row
            error: (x) ->
              # reset text
              elt.text orig

              # display errors
              addErrors $.parseJSON(x.responseText).errors
          }

      # cancel on defocus
      textbox.blur ->
        editOff elt, orig

  # callback to friend/unfriend
  editToggleFriend = ->
    elt = $(this)
    row = do elt.parent

    # clear alerts
    $(document).trigger 'clear-alerts'

    if friendsWith row
      unfriend row, elt

      # begin ajax
      $.ajax {
        method: 'DELETE',
        url: "/friendships/#{idOf(row)}",
        error: (x) ->
          # reset friend-ness
          friend row, elt

          # display errors
          addErrors $.parseJSON(x.responseText).errors
      }
    else
      friend row, elt

      # begin ajax
      $.ajax {
        method: 'POST',
        url: "/friendships",
        data: {
          id: idOf row
        }
        error: (x) ->
          # reset friend-ness
          unfriend row, elt

          # display errors
          addErrors $.parseJSON(x.responseText).errors
      }

  # callback to delete contact
  deleteContact = ->
    elt = $(this)
    row = do elt.parent

    # instant hide
    do row.hide

    # begin ajax
    $.ajax {
      method: 'DELETE',
      url: "/contacts/#{idOf(row)}",
      success: ->
        # get rid of the row for good
        do row.remove
      error: (x) ->
        # re-show
        do row.show

        # display errors
        addErrors $.parseJSON(x.responseText).errors
    }

  $ ->
    # Set up error box
    $('#alerts').bsAlerts {
      titles: {
        warning: '<em>Error!</em>',
      },
      fade: 6000
    }

    $(classify EDITABLE_TEXT).click editText
    $(classify EDITABLE_HEART).click editToggleFriend
    $(classify EDITABLE_TRASH).click deleteContact

)(window.jQuery, window._)
