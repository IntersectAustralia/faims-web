# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
show_submit_modal_dialog = ->
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

show_upload_modal_dialog = ->
  $('#upload-project-btn').click(
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

show_archive_modal_dialog = ->
  $('#archive-project-btn').click(
    ->
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
      $.ajax $(this).attr('href'),
        type: 'GET'
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          if data.archive == "true"
            setTimeout (->check_archive()),5000
            return
          else
            $('#loading').dialog('close')
            alert("Project is locked because archiving process is in progress")
            return
      return false
  )
  return

check_archive = ->
  $.ajax $('#check-archive').val(),
    type: 'GET'
    dataType: 'json'
    success: (data, textStatus, jqXHR) ->
      if data.finish == "true"
        $('#loading').dialog('close')
        window.location.href = $("#download-project").val()
        false
      else
        setTimeout (->check_archive()),5000
        return
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

delete_arch_ent_members = ->
  $('input#remove_member').each(
    -> $(this).click(
      ->
        $.post $(this).attr('src')
        $(this).parent().remove()
        return
    )
  )
  return

search_arch_ent_members = ->
  $('#search_member').click(
    ->
      window.location = $(this).attr('src')
      return
  )
  return

add_arch_ent_member = ->
  $('#add_arch_ent').click(
    ->
      selected = $('input[type="radio"]:checked')
      verb = $('#verb').val()
      if selected.length == 0
        alert('No Archaeological Entity is selected to be added')
        return false
      else
        $.ajax $(this).attr('src'),
          type: 'POST'
          data: {relationshipid: $('#relationshipid').val(), uuid: selected.val(), verb: verb}
          dataType: 'json'
          success: (data, textStatus, jqXHR) ->
            if data.result == "success"
              window.location = data.url
              return
            else
              return false
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

delete_records = ->
  $('#delete_record').one("click",
    ->
      $(this).click(
        =>
          return false
      )
      return
  )
  return

$(document).ready(
  =>
    show_submit_modal_dialog()
    show_upload_modal_dialog()
    show_archive_modal_dialog()
    compare_records()
    input_checked_handler()
    search_arch_ent_members()
    add_arch_ent_member()
    delete_arch_ent_members()
    delete_records()
    return
)