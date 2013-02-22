# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
show_modal_dialog = ->
  $('#submit-project-btn').click(
    =>
      $('#loading').dialog({
        autoOpen: false,
        closeOnEscape: false,
        draggable: false,
        title: "Message",
        width: 300,
        minHeight: 50,
        modal: true,
        buttons: {},
        resizable: false
      });
      $('#loading').removeClass('hidden')
      $('#loading').dialog('open')
      return
  )
  return

input_checked_handler = ->
  $(":checkbox").change(
    ->
      self = this
      value = $(self).val()
      if this.checked
        $('#compare').append('<input type="hidden" value="'+value+'" name="ids[]" id="'+value+ '"/>')
        $.post $('#add_entity').val(),
          value: value
      else
        $('#'+value).remove();
        $.post $('#remove_entity').val(),
          value: value
      return
  )
  return

compare_records = ->
  $('#compare').submit(

    =>
      values = $("input[name='ids[]']")
      if values.length > 2
        alert('Can only compare two records at a time')
        false
      else if values.length < 2
        alert('Please select two records to compare')
        false
  )
  return

$(document).ready(
  =>
    show_modal_dialog()
    compare_records()
    input_checked_handler()
)