# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
show_submit_modal_dialog = ->
  $('#submit-project-module-btn').click(
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
  $('#upload-project-module-btn').click(
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
  $('#archive-project-module-btn').click(
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
          if data.result == "success"
            $('#loading').addClass('hidden')
            $('#loading').dialog('destroy')
            window.location = data.url
          else if data.result == "waiting"
            setTimeout (-> check_archive(data.jobid)), 5000
          else
            $('#loading').addClass('hidden')
            $('#loading').dialog('destroy')
            alert(data.message)
          return
      return false
  )
  return

check_archive = (jobid) ->
  $.ajax $('#check-archive').val(),
    type: 'GET'
    dataType: 'json'
    data: {jobid: jobid}
    success: (data, textStatus, jqXHR) ->
      if data.result == "success"
        $('#loading').addClass('hidden')
        $('#loading').dialog('destroy')
        window.location = data.url
      else
        setTimeout (-> check_archive(jobid)), 5000
      return
  return

show_export_modal_dialog = ->
  $("[id^=export_module_]").click(
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
      form = $(this).attr('id').replace("export_module_","")
      postData = $("#" + form).find('form').serializeArray()
      $.ajax $(this).attr('href'),
        type: 'POST'
        dataType: 'json'
        data: postData
        success: (data, textStatus, jqXHR) ->
          if data.result == "success" || data.result == "failure"
            window.location = data.url
          else if data.result == "waiting"
            setTimeout (-> check_export(data.jobid)), 5000
          else
            alert("Error trying to export module. Please refresh page")
          return
      return false
  )
  return

check_export = (jobid) ->
  $.ajax $('#check-export').val(),
    type: 'GET'
    dataType: 'json'
    data: {jobid: jobid}
    success: (data, textStatus, jqXHR) ->
      if data.result != "waiting"
        window.location = data.url
      else
        setTimeout (-> check_export(jobid)), 5000
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
  $('.remove-member').each(
    -> $(this).click(
      ->
        if confirm("Are you sure you want to delete association?")
          $(this).parent('form').submit()
        return false
    )
  )

  $('#search-member').click(
    ->
      window.location = $(this).attr('src')
      return
  )

  $('input[name="relationshipid"]').change(
    ->
      typeid = $(this).siblings('input[name="typeid"]')
      $.ajax typeid.attr('src'),
        type: 'GET'
        data: {relntypeid: typeid.val()}
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          $('#verb').find('option').remove()
          if data.length
            $.each(data, ->
              $('#select-verb').append('<option value="'+ this + '">' + this + '</option>')
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
      verb = $('#select-verb').val()
      if selected.length == 0
        alert('No Archaeological Entity is selected to be added')
        return false
      else
        $('#add-arch-ent-form input[name="verb"]').val(verb)
        $('#add-arch-ent-form').submit()
        return
  )

  $('#add-rel').click(
    ->
      selected = $('input[type="radio"]:checked')
      verb = $('#select-verb').val()
      if selected.length == 0
        alert('No Relationship is selected to be added')
        return false
      else
        $('#add-rel-form input[name="verb"]').val(verb)
        $('#add-rel-form').submit()
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
      form = $('<form method="post">')
      form.attr('action',$(this).attr('href'))
      $('#select-form').find('.merge-row').each (
        ->
          if ($(this).find('.merge-left').find('input:radio:checked').length)
            row = $(this).find('.merge-left')
          else
            row = $(this).find('.merge-right')
          row.find('input').each(
            ->
              form.append($(this).clone())
          )
          return
      )

      # open modal dialog
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
        type: 'POST'
        dataType: 'json'
        data: form.serialize()
        success: (data, textStatus, jqXHR) ->
          if data.result == 'success'
            window.location = data.url
          else
            $('#loading').addClass('hidden')
            $('#loading').dialog('destroy')
            alert(data.message)
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
  temp_id = 0
  $('.show input[name="temp_id[]"]').each(
    ->
      if $(this).val() != "" && $(this).val() != undefined
        if temp_id < parseInt($(this).val())
          temp_id = parseInt($(this).val())
  )
  temp_id = temp_id + 1

  select_vocabs = ->
    value = $('#attribute').val()

    $('.vocab-list').removeClass('show')
    $('.vocab-list').addClass('hide')
    $('.vocab-list-' + value).removeClass('hide')
    $('.vocab-list-' + value).addClass('show')

    if (value == "")
      $('#update_vocab').addClass('hide')
    else
      $('#update_vocab').removeClass('hide')

  $('#attribute').change(
    ->
      select_vocabs()

      # remove newly inserted vocabs
      $('.vocab-new').remove()

      return
  )

  $(document).on('click', '.insert-new-vocab',
    ->
      parent_vocab_id = $($(this).parent('.vocab-row').children('div')[0]).find('input[name="parent_vocab_id[]"]').val()
      parent_id = $($(this).parents('.vocab-row').children('div')[0]).find('input[name="temp_parent_id[]"]').val()

      value = '<div class="vocab-new vocab-row well" ><input class="span3" type="hidden" name="temp_id[]" value="' + temp_id + '"/>'
      if parent_id == undefined
        value += '<input class="span3" type="hidden" name="temp_parent_id[]"/>'
      else
        value += '<input class="span3" type="hidden" name="temp_parent_id[]" value="'+ parent_id + '"/>'

      if parent_vocab_id == undefined
        value += '<input class="span3" type="hidden" name="parent_vocab_id[]"/>'
      else
        value += '<input class="span3" type="hidden" name="parent_vocab_id[]"value="'+ parent_vocab_id + '"/>'

      value += '<input class="span3" type="hidden" name="vocab_id[]"/><input class="span3" type="text" name="vocab_name[]"/> '
      value += '<input class="span3" type="text" name="vocab_description[]"/> <input class="span3" type="text" name="picture_url[]"/> '
      value += '<a href="#" class="btn add-child">Add Child</a></div>'
      temp_id += 1
      $(this).before($(value).fadeIn('slow'))
      return false
  )

  $(document).on('click', '.add-child',
  ->
    div = $(this).parents('div')[0]
    parent_vocab_id = $(div).find('input[name="vocab_id[]"]').val()
    parent_id = $(div).find('input[name="temp_id[]"]').val()
    value = '<div class="vocab-row" style="margin-left: 25px"><div class="vocab-new vocab-row well"><input class="span3" type="hidden" name="temp_id[]" value="' + temp_id + '"/>'
    if parent_id == ""
      value += '<input class="span3" type="hidden" name="temp_parent_id[]"/>'
    else
      value += '<input class="span3" type="hidden" name="temp_parent_id[]" value="'+parent_id+'"/>'

    if parent_vocab_id == ""
      value += '<input class="span3" type="hidden" name="parent_vocab_id[]"/>'
    else
      value += '<input class="span3" type="hidden" name="parent_vocab_id[]" value="'+ parent_vocab_id + '"/>'

    value += '<input class="span3" type="hidden" name="vocab_id[]"/><input class="span3" type="text" name="vocab_name[]"/> '
    value += '<input class="span3" type="text" name="vocab_description[]"/> <input class="span3" type="text" name="picture_url[]"/> '
    value += '<a href="#" class="btn add-child">Add Child</a></div><a href="#" class="btn btn-block insert-new-vocab" style="display:block">Insert</a></div>'
    if $(div).find('.insert-new-vocab').length == 0
      $(div).append($(value).fadeIn('slow'))
    else
      $(div).find('.insert-new-vocab').before($(value).fadeIn('slow'))
    $(this).remove()
    temp_id += 1

    return false
  )

  $('#update_vocab').click(
    ->
      $('.vocab-list.hide').remove()
      $('#attribute_form').submit();
      return false
  )

  select_vocabs()
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

update_attribute = (form) ->
  # open modal dialog
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
    type: 'POST'
    dataType: 'json'
    data: form.serialize()
    success: (data, textStatus, jqXHR) ->
      form.find('#attr_ignore_errors').val('')
      if data.result == 'success'
        form.find('.form-attribute-error').remove()
        if data.errors
          errors = data.errors.split(';')
          for error in errors
            if error != ""
              form.find('.row-fluid').after("<div class='form-attribute-error'><li>"+error+"</li></div>")

          # hide update button
          if form.find('.ignore-errors-btn').hasClass('hidden')
            form.find('.ignore-errors-btn').removeClass('hidden')
        else
          form.find('.row-fluid').after("<div class='alert alert-success alert-dismissable'><button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;</button>Updated</div>")
          setTimeout(
            ->
              form.find('.alert').fadeOut()
            , 2000)
          # show update button
          if !form.find('.ignore-errors-btn').hasClass('hidden')
            form.find('.ignore-errors-btn').addClass('hidden')
      else
        alert(data.message)

      $('#loading').addClass('hidden')
      $('#loading').dialog('destroy')

update_arch_ent_or_rel = ->
  $('.update-arch-ent-form form').submit(
    ->
      update_attribute($(this))
      return false
  )
  $('.update-rel-form form').submit(
    ->
      update_attribute($(this))
      return false
  )

$(document).ready(
  =>
    show_submit_modal_dialog()
    show_upload_modal_dialog()
    show_archive_modal_dialog()
    show_export_modal_dialog()
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
    update_arch_ent_or_rel()
    return
)
