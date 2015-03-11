# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require jquery.bsAlerts.min
#= require lodash.min

(($, _) -> $ ->

  NEW_TEXT = 'new-text'
  NEW_HEART = 'new-heart'
  NEW_PLUS = 'new-plus'

  EDITABLE_TEXT = 'editable-text'
  EDITABLE_HEART = 'editable-heart'
  EDITABLE_TRASH = 'editable-trash'
  EDITING = 'editable-text-editing'

  TEXT_INPUT = (val) ->
    "<input type='text' value='#{val}' />"
  HEART_TOGGLE = (turnon) ->
    "<span class='glyphicon glyphicon-heart#{if turnon then '' else '-empty'}'>"
  NEW_CONTACT = (id, friended, name, email, phone) -> "
    <tr class='existing-contact' data-id='#{id}' data-friended='#{if friended then 1 else 0}'>
      <td class='add-delete editable-trash'>
        <span class='glyphicon glyphicon-trash'></span>
      </td>
      <td class='is-friend editable-heart'>
        <span class='glyphicon glyphicon-heart#{if friended then '' else '-empty'}'></span>
      </td>
      <td class='name editable-text'>
        #{name}
      </td>
      <td class='email editable-text'>
        #{email}
      </td>
      <td class='name editable-text'>
        #{phone}
      </td>
  "

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
  contactInfoFor = (row, input = false) ->
    namecell =  $(row.children('.name')[0])
    emailcell = $(row.children('.email')[0])
    phonecell =   $(row.children('.phone')[0])

    if input
      {
        name: do $(namecell.find('input')[0]).val
        email: do $(emailcell.find('input')[0]).val
        phone: do $(phonecell.find('input')[0]).val
      }
    else
      {
        name: do namecell.text
        email: do emailcell.text
        phone: do phonecell.text
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

  # inputs for new contact
  $newInputs = $(classify NEW_TEXT).find('input')

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
            url: "/contacts/#{idOf row}",
            data: contactInfoFor(row),
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
        url: "/friendships/#{idOf row}",
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
        },
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
      url: "/contacts/#{idOf row}",
      success: ->
        # get rid of the row for good
        do row.remove
      error: (x) ->
        # re-show
        do row.show

        # display errors
        addErrors $.parseJSON(x.responseText).errors
    }

  # callback to set friend status on new contact
  addTogggleFriend = ->
    elt = $(this)
    row = do elt.parent

    if friendsWith row
      unfriend row, elt
    else
      friend row, elt

  # callback to add contact
  addContact = ->
    elt = $(this)
    row = do elt.parent
    console.log row

    # clear alerts
    $(document).trigger 'clear-alerts'

    # don't instant add - let server vaidate first
    # (too lazy for client-side validation with jquery...)
    $.ajax {
      method : 'POST',
      url: "/contacts",
      data: contactInfoFor(row, true),

      success: (data) ->
        # register friend if necessary
        if friendsWith(row)
          $.ajax {
            method: 'POST',
            url: "/friendships",
            data: {
              id: data.id
            },
            success: ->
              # insert the new row after this one
              row.after NEW_CONTACT data.id, true, data.name, data.email, data.phone
            error: (x) ->
              # insert the new row after this one, without friends
              row.after NEW_CONTACT data.id, false, data.name, data.email, data.phone

              # display errors
              addErrors $.parseJSON(x.responseText).errors
          }
        else
          row.after NEW_CONTACT data.id, false, data.name, data.email, data.phone

        # clear input
        $newInputs.val ''
        unfriend row, $(NEW_HEART)

      error: (x)->
        # display errors
        addErrors $.parseJSON(x.responseText).errors
    }

  # Set up error box
  $('#alerts').bsAlerts {
    titles: {
      warning: '<em>Error!</em>',
    },
    fade: 6000
  }

  # enter key on new contact fields
  $newInputs.keypress (e) ->
    if e.which == 13
      addContact.call $(this).parent()

  $(classify NEW_HEART).click addTogggleFriend
  $(classify NEW_PLUS).click addContact

  $(classify EDITABLE_TEXT).click editText
  $(classify EDITABLE_HEART).click editToggleFriend
  $(classify EDITABLE_TRASH).click deleteContact

)(window.jQuery, window._)
