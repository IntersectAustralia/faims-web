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
          if data.result == "success"
            $('#loading').dialog('destroy')
            window.location = data.url
          else if data.result == "waiting"
            setTimeout (-> check_archive(data.jobid)), 5000
          else
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
        $('#loading').dialog('destroy')
        window.location = data.url
      else
        setTimeout (-> check_archive(jobid)), 5000
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
  select_vocabs = ->
    value = $('#attribute').val()

    $('.vocab-list').removeClass('show')
    $('.vocab-list').addClass('hide')
    $('.vocab-list-' + value).removeClass('hide')
    $('.vocab-list-' + value).addClass('show')

    if (value == "")
      $('#insert_vocab').addClass('hide')
      $('#update_vocab').addClass('hide')
    else
      $('#insert_vocab').removeClass('hide')
      $('#update_vocab').removeClass('hide')

  $('#attribute').change(
    ->
      select_vocabs()

      # remove newly inserted vocabs
      $('.vocab-new').remove()

      return
  )

  $('#insert_vocab').click(
    ->
      value = '<tr class="vocab-new"><td><input type="hidden" name="vocab_id[]"/><input name="vocab_name[]"/></td>'
      value += '<td><input name="vocab_description[]"/></td><td><input name="picture_url[]"/></td></tr>'
      table = $('#vocab-content').find('.vocab-list.show')
      $(value).appendTo($(table))
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
      if data.result == 'success'
        form.find('.form-attribute-result').empty()
        if data.errors
          errors = data.errors.split(';')
          for error in errors
            if error != ""
              form.find('.form-attribute-result').append("<li class='form-attribute-error'>"+error+"</li>")

          # hide update button
          if form.find('.ignore-errors-btn').hasClass('hidden')
            form.find('.ignore-errors-btn').removeClass('hidden')
        else
          form.find('.form-attribute-result').append("<div class='alert alert-success alert-dismissable'><button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;</button>Updated</div>")
          setTimeout(
            ->
              form.find('.form-attribute-result .alert').fadeOut()
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
