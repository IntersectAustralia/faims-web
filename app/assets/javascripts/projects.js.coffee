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
            alert("Could not process request as project is currently locked")
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

compare_input_checked_handler = ->
  $('#compare input:checkbox').change(
    ->
      self = this
      value = $(self).val()
      identifier_input = $(this).siblings('#identifier')
      identifier_value = $(identifier_input).val()
      timestamp_input = $(this).siblings('#timestamp')
      timestamp_value = $(timestamp_input).val()
      if this.checked
        $('#compare').append('<input type="hidden" value="'+value+'" name="ids[]" id="'+value+ '"/>')
        $('#compare').append('<input type="hidden" value="'+identifier_value+'" name="identifiers[]" id="'+value+ '"/>')
        $('#compare').append('<input type="hidden" value="'+timestamp_value+'" name="timestamps[]" id="'+value+ '"/>')
        $.post $('#add-entity').val(),
          value: value,
          identifier: identifier_value,
          timestamp: timestamp_value
      else
        $('input[id='+value+']').remove();
        $.post $('#remove-entity').val(),
          value: value,
          identifier: identifier_value,
          timestamp: timestamp_value
      return
  )
  return

aent_rel_management = ->
  $('#remove-member').each(
    -> $(this).click(
      ->
        if confirm("Are you sure you want to delete association?")
          $.post $(this).find('a').attr('href')
          $(this).parent('li').remove()
        return false
    )
  )

  $('#search-member').click(
    ->
      window.location = $(this).attr('src')
      return
  )

  $('input[name="rel_id"]').change(
    ->
      $relntypeid = $(this).siblings('#relntypeid')
      $.ajax $relntypeid.attr('src'),
        type: 'GET'
        data: {relntypeid: $('#relntypeid').val()}
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          $('#verb').find('option').remove()
          if data.length
            $.each(data, ->
              $('#verb').append('<option value="'+ this + '">' + this + '</option>')
              return
            )
            return
          else
            return false
      return
  )

  $('#add-arch-ent').click(
    ->
      selected = $('input[type="radio"]:checked')
      verb = $('#verb').val()
      if selected.length == 0
        alert('No arch entity is selected to be added')
        return false
      else
        $.ajax $(this).attr('src'),
          type: 'POST'
          data: {relationshipid: $('#relationshipid').val(), relntypeid: $('#relntypeid').val(), uuid: selected.val(), verb: verb}
          dataType: 'json'
          success: (data, textStatus, jqXHR) ->
            if data.result == "success"
              window.location = data.url
              return
            else
              return false
        return
  )

  $('#add-rel').click(
    ->
      selected = $('input[type="radio"]:checked')
      verb = $('#verb').val()
      if selected.length == 0
        alert('No relationship is selected to be added')
        return false
      else
        $.ajax $(this).attr('src'),
          type: 'POST'
          data: {relationshipid: selected.val(), uuid: $('#uuid').val(), verb: verb}
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
  $('#compare-button').click(
    ->
      href = $(this).attr('href')
      $form = $('#compare')
      values = $("input[name='ids[]']")
      if values.length > 2
        alert('Can only compare two records at a time')
        false
      else if values.length < 2
        alert('Please select two records to compare')
        false
      else
        $form.attr('action', href)
        $form.submit()
        false
  )
  return

download_attached_file = ->
  $('form[id*=download-attached-file]').each(
    ->
      self = this
      $a_href = $(this).find('a')
      $a_href.click(
        ->
          $(self).submit()
          return false
      )
      return
  )
  return

merge_record_management = ->
  $('#select-first').click(
    ->
      $('#select-form input:radio').each(
        ->
          $(this).prop('checked',false)
          li_sibling = $(this).parents('tr').siblings()
          if(li_sibling.length)
            $(li_sibling).find('td.second').removeClass('selected')
            return
          return
      )
      $('td.first input:radio').each(
        ->
          $(this).prop('checked',true)
          li_sibling = $(this).parents('tr').siblings()
          if(li_sibling.length)
            $(li_sibling).find('td.first').addClass('selected')
            return
          return
      )
  )
  $('#select-second').click(
    ->
      $('#select-form input:radio').each(
        ->
          $(this).prop('checked',false)
          li_sibling = $(this).parents('tr').siblings()
          if(li_sibling.length)
            $(li_sibling).find('td.first').removeClass('selected')
            return
          return
      )
      $('td.second input:radio').each(
        ->
          $(this).prop('checked',true)
          li_sibling = $(this).parents('tr').siblings()
          if(li_sibling.length)
            $(li_sibling).find('td.second').addClass('selected')
            return
          return
      )
  )

  $('#select-form input:radio').change(
    ->
      isLeft = $(this).parents('td').hasClass('merge-left')
      row = $(this).parents('.merge-row')
      if isLeft
        row.find('.merge-right').find('input:radio').prop('checked', false)
        row.find('.merge-left').find('input:radio').prop('checked', true)
        row.find('.merge-right').removeClass('selected')
        row.find('.merge-left').addClass('selected')
      else
        row.find('.merge-right').find('input:radio').prop('checked', true)
        row.find('.merge-left').find('input:radio').prop('checked', false)
        row.find('.merge-right').addClass('selected')
        row.find('.merge-left').removeClass('selected')
  )


  $('#merge-record').click(
    ->
      $form = $('<form method="post">')
      $form.attr('action',$(this).attr('href'))
      $('#select-form').find('.merge-row').each (
        ->
          if ($(this).find('.merge-left').find('input:radio:checked').length)
            row = $(this).find('.merge-left')
          else
            row = $(this).find('.merge-right')
          row.find('input').each(
            ->
              $form.append(this)
          )
          return
      )
      $('body').append($form)
      $form.hide()
      $form.submit()
      false
  )
  return

ignore_error_records = ->
  $('.ignore-errors-btn').click(
    ->
      form = $(this).closest('form')
      form.find('#attr_ignore_errors').val('1')
      return true
  )

history_management = ->
  $('input[type="radio"]:checked').each(
    ->
      name = $(this).attr('name')
      selector = 'input[type="radio"][name="' + name + '"]'
      $(selector).parents('td').removeClass('selected')
      $(this).parents('td').addClass('selected')
  )
  $('input[type="radio"]').change(
    ->
      name = $(this).attr('name')
      selector = 'input[type="radio"][name="' + name + '"]'
      $(selector).parents('td').removeClass('selected')
      $(this).parents('td').addClass('selected')
  )
  $('.history-select-btn').click(
    ->
      $(this).parents('tr').find('input[type="radio"]').click()
      return false
  )
  $('.history-form').submit(
    ->
      $('input[type="radio"]:not(:checked)').each(
        ->
          $(this).parents('td').find('input[type="hidden"]').remove()
      )
  )
  $('.history-resolve-btn').click(
    ->
      $('input[name="resolve"]').val('true')
  )

vocab_management = ->
  $('#attribute').change(
    ->
      value = $(this).val()
      selected = $(this).find('option:selected');
      url = selected.data('url')
      $('#vocab-content').empty()
      if (value == "")
        $('#update_vocab').addClass('hidden')
        $('#insert_vocab').addClass('hidden')
        return
      else
        $('#update_vocab').removeClass('hidden')
        $('#insert_vocab').removeClass('hidden')
        $.get url, (data) ->
          $('<label>Vocab List</label>').appendTo($('#vocab-content'))
          table = $('<table></table>').appendTo($('#vocab-content'))
          $(data).each(
            ->
              value = '<tr><td><input type="hidden" name="vocab_id[]" value="'+this.vocab_id+'"/><input name="vocab_name[]"value="'+this.vocab_name+'"/></td></tr>'
              $(value).appendTo($(table))
              return
          )
          return
        return
      return
  )

  if ($('#attribute').val() != "")
    $('#attribute').change()
    $('#insert_vocab').click(
      ->
        value = '<tr><td><input type="hidden" name="vocab_id[]"/><input name="vocab_name[]"/></td></tr>'
        table = $('#vocab-content').find('table')
        $(value).appendTo($(table))
        return false
    )

    $('#update_vocab').click(
      ->
        $('#attribute_form').submit();
        return false
    )
    return

  $('#insert_vocab').click(
    ->
      value = '<tr><td><input type="hidden" name="vocab_id[]"/><input name="vocab_name[]"/></td></tr>'
      table = $('#vocab-content').find('table')
      $(value).appendTo($(table))
      return false
  )

  $('#update_vocab').click(
    ->
      $('#attribute_form').submit();
      return false
  )
  return

user_management = ->
  $('#add_user').click(
    ->
      if $('#select_user').val() != ""
        $('#user_form').submit()
        return false
      return false
  )
  return

show_hide_deleted = ->
  $('#show-hide-deleted').click(
    ->
      $('#show-hide-deleted-form').submit()
      return false
  )
  return

$(document).ready(
  =>
    show_submit_modal_dialog()
    show_upload_modal_dialog()
    show_archive_modal_dialog()
    compare_records()
    compare_input_checked_handler()
    aent_rel_management()
    download_attached_file()
    ignore_error_records()
    merge_record_management()
    history_management()
    vocab_management()
    user_management()
    show_hide_deleted()
    return
)
