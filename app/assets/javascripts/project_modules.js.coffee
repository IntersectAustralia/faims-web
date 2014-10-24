# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


# GLOBAL VARIABLES
should_save = false
form_data = null


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
          if data.result == "success" || data.result == "failure"
            $('#loading').addClass('hidden')
            $('#loading').dialog('destroy')
            window.location = data.url
          else if data.result == "waiting"
            setTimeout (-> check_archive(data.jobid)), 5000
          else
            $('#loading').addClass('hidden')
            $('#loading').dialog('destroy')
            alert("Error trying to archive module. Please refresh page")
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
      if data.result != "waiting"
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
      if $("#" + form).find("*").filter('[required]:visible').filter(-> return $(this).val().trim() == "").size() != 0
        $('#loading').addClass('hidden')
        $('#loading').dialog('destroy')
        return
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
        alert('No Entity is selected to be added')
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
      values = $('input[name="id"]:checked')
      if values.length > 2
        alert('Can only compare two records at a time')
        false
      else if values.length < 2
        alert('Please select two records to compare')
        false
      else
        window.location = href + "&ids[]=" + $(values[0]).val() + "&ids[]=" + $(values[1]).val()
        false
  )
  return

bulk_delete_restore_entities = ->
  $('#delete-selected-button').click(
    ->
      values = $(':checkbox:checked').map(
        ->
          return $(this).val();
      ).get();
      if values.length == 0
        alert('Please select a record to delete')
        false
      else
        if confirm("Are you sure you want to delete these records?")
          href = $(this).attr('href')
          $form = $('#delete-ent-form')
          $('#selected-ents-delete').val(values.toString())
          $form.attr('action', href)
          $form.submit()
          false
      return false
  )

  $('#restore-selected-button').click(
    ->
      values = $(':checkbox:checked').filter('.restore').map(
        ->
          return $(this).val();
      ).get();
      if values.length == 0
        alert('Please select a record to restore')
        false
      else
        if confirm("Are you sure you want to restore these records?")
          href = $(this).attr('href')
          $form = $('#restore-ent-form')
          $('#selected-ents-restore').val(values.toString())
          $form.attr('action', href)
          $form.submit()
          false
      return false
  )
  return

bulk_delete_restore_related_entities = ->
  $('#delete-selected-related-ents-button').click(
    ->
      values = $(':checkbox:checked').filter('.delete').map(
        ->
          return $(this).val();
      ).get();
      if values.length == 0
        alert('Please select a record to delete')
        false
      else
        if confirm("Are you sure you want to delete these records?")
          href = $(this).attr('href')
          $form = $('#delete-rel-form')
          $('#selected-rels-delete').val(values.toString())
          $form.attr('action', href)
          $form.submit()
          false
      return false
  )

  $('#restore-selected-related-ents-button').click(
    ->
      values = $(':checkbox:checked').filter('.restore').map(
        ->
          return $(this).val();
      ).get();
      if values.length == 0
        alert('Please select a deleted record to restore')
        false
      else
        if confirm("Are you sure you want to restore these records?")
          href = $(this).attr('href')
          $form = $('#restore-rel-form')
          $('#selected-rels-restore').val(values.toString())
          $form.attr('action', href)
          $form.submit()
          false
      return false
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
      row = $(this).parents('.vocab-container:first').find('tr:first').next()

      parent_temp_id = row.find('input[name="parent_temp_id[]"]').val()
      parent_vocab_id = row.find('input[name="parent_vocab_id[]"]').val()

      value = '<tr><td>'
      value += '<input name="temp_id[]" type="hidden" value="' + temp_id + '"/>'
      if parent_temp_id == undefined
        value += '<input name="parent_temp_id[]" type="hidden"/>'
      else
        value += '<input name="parent_temp_id[]" type="hidden" value="'+ parent_temp_id + '"/>'
      value += '<input name="vocab_id[]" type="hidden"/>'
      if parent_vocab_id == undefined
        value += '<input name="parent_vocab_id[]" type="hidden"/>'
      else
        value += '<input name="parent_vocab_id[]" type="hidden" value="'+ parent_vocab_id + '"/>'
      value += '<div class="span2"><input class="span2" name="vocab_name[]" type="text"/></div>'
      value += '<div class="span2"><input class="span2" name="vocab_description[]" type="text"/></div>'
      value += '<div class="span2"><input class="span2" name="picture_url[]" type="text"/></div>'
      value += '<div class="span3">'
      value += '<a href="#" class="btn vocab-button move-up"><i class="icon-arrow-up"/></a>'
      value += '<a href="#" class="btn vocab-button move-down"><i class="icon-arrow-down"/></a>'
      value += '<a href="#" class="btn vocab-button add-child">Add Child</a>'
      value += '</div>'
      value += '</td></tr>'

      temp_id += 1

      $(this).parents('.vocab-container:first').find('tr:last').before($(value))

      return false
  )

  $(document).on('click', '.add-child',
  ->
    row = $(this).parents('tr:first')

    parent_temp_id = row.find('input[name="temp_id[]"]').val()
    parent_vocab_id = row.find('input[name="vocab_id[]"]').val()

    value = '<table class="vocab-container" style="margin-left: 25px"><tbody>'

    value += '<tr><td>'
    value += '<div class="span2"><label class="span2">Name</label></div>'
    value += '<div class="span2"><label class="span2">Description</label></div>'
    value += '<div class="span2"><label class="span2">Picture URL</label></div>'
    value += '<div class="span3"></div>'
    value += '</td></tr>'

    value += '<tr><td>'
    value += '<input name="temp_id[]" type="hidden" value="' + temp_id + '"/>'
    if parent_temp_id == undefined
      value += '<input name="parent_temp_id[]" type="hidden"/>'
    else
      value += '<input name="parent_temp_id[]" type="hidden" value="'+ parent_temp_id + '"/>'
    value += '<input name="vocab_id[]" type="hidden"/>'
    if parent_vocab_id == undefined
      value += '<input name="parent_vocab_id[]" type="hidden"/>'
    else
      value += '<input name="parent_vocab_id[]" type="hidden" value="'+ parent_vocab_id + '"/>'
    value += '<div class="span2"><input class="span2" name="vocab_name[]" type="text"/></div>'
    value += '<div class="span2"><input class="span2" name="vocab_description[]" type="text"/></div>'
    value += '<div class="span2"><input class="span2" name="picture_url[]" type="text"/></div>'
    value += '<div class="span3">'
    value += '<a href="#" class="btn vocab-button move-up"><i class="icon-arrow-up"/></a>'
    value += '<a href="#" class="btn vocab-button move-down"><i class="icon-arrow-down"/></a>'
    value += '<a href="#" class="btn vocab-button add-child">Add Child</a>'
    value += '</div>'
    value += '</td></tr>'

    value += '<tr class="insert-row"><td><div class="span2"><a href="#" class="btn vocab-button insert-new-vocab">Insert</a></div></td></tr>'
    value += '</tbody></table>'

    temp_id += 1

    row.find('td').append($(value))
    $(this).remove()

    return false
  )

  $(document).on('click', '.move-up',
  ->
    row = $(this).parents('tr:first')
    unless row.prev().prev().size() == 0
      row.prev().before(row)
    return false
  )

  $(document).on('click', '.move-down',
  ->
    row = $(this).parents('tr:first')
    unless row.next().next().size() == 0
      row.next().after(row)
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

add_attribute = (button) ->
  value = $(button).parents('.attribute-value')
  clone_value = value.clone()
  setup_attribute_value(clone_value)
  if (value.next().hasClass('form-attribute-error'))
    value = value.next()
  clone_value.find('.attribute-upload-file').hide()
  clone_value.insertAfter(value)
  autosave_entity_attributes()

remove_attribute = (button) ->
  value = $(button).parents('.attribute-value')
  form = $(button).parents('.update-arch-ent-form')
  count = form.find('.attribute-value').size()
  if count > 1
    value.remove()
    if value.find('.attribute-upload-file').length > 0
      form.find('.attribute-upload-file').first().show()
  else if count == 1
    clear_attribute_value(value)
  should_save = true

clear_attribute_value = (value) ->
  attribute_name = value.find('.attribute-name').text()
  vocab = value.find('[name="attr['+attribute_name+'][vocab_id][]"]')
  if vocab
    vocab.val('')
  value.find('[name="attr['+attribute_name+'][measure][]"]').val('')
  value.find('[name="attr['+attribute_name+'][freetext][]"]').val('')
  value.find('[name="attr['+attribute_name+'][certainty][]"]').val('')
  value.find('.form-attribute-error').remove()

setup_attribute_value = (value) ->
  clear_attribute_value(value)
  value.find('.add-attribute').click(
    ->
      add_attribute($(this))
      return false
  )
  value.find('.remove-attribute').click(
    ->
      remove_attribute($(this))
      return false
  )
  value.find('.attribute-upload-file').click(
    ->
      upload_file($(this))
  )

create_attribute_value = (value, data) ->
  v = value.clone()

  clear_attribute_value(v)
  setup_attribute_value(v)

  vocab = v.find('[name="attr['+data.name+'][vocab_id][]"]')
  if vocab
    vocab.val(data.vocab)
  v.find('[name="attr['+data.name+'][measure][]"]').val(data.measure)
  v.find('[name="attr['+data.name+'][freetext][]"]').val(data.freetext)
  v.find('[name="attr['+data.name+'][certainty][]"]').val(data.certainty)

  if data.errors
    errors = data.errors.split(';')
    for error in errors
      if error != ""
        node = v.find('label h4')
        while (node.next().hasClass('form-attribute-error'))
          node = node.next()
        node.after("<div class='form-attribute-error'><span>"+error+"</span></div>")

  return v

update_arch_ent_or_rel = ->
  $('.add-attribute').click(
    ->
      add_attribute($(this))
      return false
  )
  $('.remove-attribute').click(
    ->
      remove_attribute($(this))
      return false
  )
  $('.attribute-upload-file').click(
    ->
      upload_file($(this))
  )

setup_attribute_groups = ->
  if $('.update-arch-ent-form').length > 0
    show_loading_dialog()

    $.ajax $('#setup-attributes').attr('href'),
      type: 'GET'
      dataType: 'json'
      cache: false
      success: (data, textStatus, jqXHR) ->
        for index in [0...data.result.length]
          form = $('form')[index]
          initial_setup_attribute($(form), data.result[index], true)
        autosave_entity_attributes()
        $('.file-measure').prop('readonly', true);
        form_data = $('.attr').serialize()
        $('#setting_up').dialog('destroy')
        $('#setting_up').addClass('hidden')

    $(document).idle({
      onIdle:
        ->
          current_form_data = $('.attr').serialize()
          if should_save and current_form_data != form_data
            should_save = false
            show_loading_dialog()
            autosave(false)
      , idle: 5000
      events: 'keypress mousedown'
    })

    $(window).unload(
      ->
        current_form_data = $('.attr').serialize()
        if should_save and current_form_data != form_data
          should_save = false
          autosave(true)
        return false
    )

    $('.logo').parent().prepend('<p><b>This page will automatically update any changes to this entity and will update again upon navigating away from this page</b></p>')
    return false

initial_setup_attribute = (form, data, updated) ->
  form.find('#attr_ignore_errors').val('')

  if data != 'failure'

    value = form.find('.attribute-value:first')
    form.find('.attribute-value').remove()

    has_error = false
    for value_data, index in data['values']
      clone_value = create_attribute_value(value, value_data)
      if index != 0
        clone_value.find('.ignore-errors-chk').remove()
        clone_value.find('.attribute-upload-file').hide()
      form.find('.arch_ent_record_content').append(clone_value)
      if value_data.errors
        has_error = true

    if has_error
      # hide update button
      if form.find('.ignore-errors-chk').hasClass('hidden')
        form.find('.ignore-errors-chk').removeClass('hidden')
      form.find('#attr_ignore_errors').prop('checked', false);
    else
      # show update button
      if !form.find('.ignore-errors-chk').hasClass('hidden')
        form.find('.ignore-errors-chk').addClass('hidden')

autosave_entity_attributes = ->
  $('input[name^="attr"]').on('blur',
    ->
      should_save = true
      return false
  )

  $('select[name*="[vocab_id]"]').change(
    ->
      should_save = true
      return false
  )

  $('input[name*="[ignore_errors]"]').click(
    ->
      should_save = true
      if this.checked
        $(this).val(1)
      else
        $(this).val("")
  )

autosave = (on_unload) ->
  $.ajax $('#update-all').attr('href'),
    type: 'POST'
    async: false
    dataType: 'json'
    data: $('.attr').serialize()
    success: (data, textStatus, jqXHR) ->
      if data.result != 'failure'
        $.toast('Successfully updated entity', 2500, 'success');
        if !on_unload
          for index in [0...data.result.length]
            form = $('form')[index]
            initial_setup_attribute($(form), data.result[index], true)
          autosave_entity_attributes()
          $('.file-measure').prop('readonly', true);
          form_data = $('.attr').serialize()
      else
        alert(data.message)
      if !$('#setting_up').hasClass('hidden')
        $('#setting_up').dialog('destroy')
        $('#setting_up').addClass('hidden')
  return false

upload_file = (button) ->
  form = $(button).parents('.update-arch-ent-form')
  attr_id = form.find('#attr_attribute_id').val()
  $('#attribute-file-upload').find('#attr_file_attribute_id').val(attr_id)

  # open modal dialog
  $('#attribute-file-upload').dialog({
    autoOpen: false,
    closeOnEscape: true,
    draggable: false,
    title: "Upload file/s",
    width: 400,
    minHeight: 50,
    modal: true,
    buttons: {
      "Upload": ->
        $('#uploading_files').dialog({
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
        $('#uploading_files').removeClass('hidden')
        $('#uploading_files').dialog('open')
        upload_form = $('#attribute-file-upload').find('form')
        $.ajax upload_form.attr('action'),
          type: 'POST'
          dataType: 'json'
          data: upload_form.serializeArray()
          files: $(":file", this)
          iframe: true
          processData: false
          success: (data, textStatus, jqXHR) ->
            if data.result != 'failure'
              free = find_create_free_field(form)
              for file, index in data.uploaded_files
                free.find('#attr_measure').val(file)
                if index != data.uploaded_files.length-1
                  add_attribute(free.find('.add-attribute'))
                  free = form.find('.attribute-value').last()
              $.toast('Successfully uploaded file/s', 2500, 'success');
            else
              alert(data.message)
            $('#uploading_files').dialog('destroy')
            $('#uploading_files').addClass('hidden')

        should_save = true
        form_data = null
        $('.attr_file').trigger("reset")
        $('#attribute-file-upload').find('#attr_file_attribute_id').val("")
        $(this).dialog('close');
      Cancel: ->
        $('.attr_file').trigger("reset")
        $('#attribute-file-upload').find('#attr_file_attribute_id').val("")
        $(this).dialog('close');
    },
    resizable: false
  });
  $('#attribute-file-upload').removeClass('hidden')
  $('#attribute-file-upload').dialog('open')
  return false

find_create_free_field = (form) ->
  for row in form.find('.attribute-value')
    if $(row).find('#attr_measure').val() == "" && $(row).find('#attr_freetext').val() == "" && $(row).find('#attr_certainty').val() == ""
      return $(row)
  add_attribute(form.find('.attribute-value').last().find('.add-attribute'))
  return form.find('.attribute-value').last()

show_loading_dialog = ->
  # open modal dialog
  $('#setting_up').dialog({
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
  $('#setting_up').removeClass('hidden')
  $('#setting_up').dialog('open')

datatables_setup = ->
  $('.search-table').dataTable(
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bPaginate": false,
    "bFilter": false,
  );
  return

setup_server_updates = ->
  $('.archive-module-btn').click(
    ->
      button = $(this)
      if (button.hasClass('disabled'))
        return

      button.addClass('btn-primary disabled')

      $.ajax button.attr('href'),
        type: 'GET'
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          if data.result == "success"
            $(this).addClass('hidden')
            $(this).removeClass('btn-primary disabled')
            $(this).parent().children('.download-module-btn').removeClass('hidden')
          else if data.result == "waiting"
            check_archive_for_server_update_page(button, data.jobid)
          else
            alert(data.message)
            $(this).removeClass('btn-primary disabled')
            $(this).parent().children('.download-module-btn').addClass('hidden')

      return false
  )

  $('.update-server-btn').click(
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
        type: 'POST'
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          if data.result == "success"
            check_server_updated(data.url)
          else
            alert(data.message)
            $('#loading').addClass('hidden')
            $('#loading').dialog('destroy')

      return false
  )

check_archive_for_server_update_page = (button, jobid) ->
  $.ajax button.attr('data-check'),
    type: 'GET'
    dataType: 'json'
    data: {jobid: jobid}
    success: (data, textStatus, jqXHR) ->
      if data.result == "success"
        button.addClass('hidden')
        button.removeClass('btn-primary disabled')
        button.parent().children('.download-module-btn').removeClass('hidden')
      else if data.result == "waiting"
        setTimeout (-> check_archive_for_server_update_page(button, jobid)), 5000
      else
        alert(data.message)
        button.removeClass('btn-primary disabled')
        button.parent().children('.download-module-btn').addClass('hidden')

check_server_updated = (url) ->
  $.ajax url,
    type: 'GET'
    dataType: 'json'
    success: (data, textStatus, jqXHR) ->
      if data.result == "success"
        window.location = data.url
      else
        setTimeout (-> check_server_updated(url)), 5000

$(document).ready(
  =>
    show_submit_modal_dialog()
    show_upload_modal_dialog()
    show_archive_modal_dialog()
    show_export_modal_dialog()
    compare_records()
    bulk_delete_restore_entities()
    bulk_delete_restore_related_entities()
    aent_rel_management()
    download_attached_file()
    ignore_error_records()
    merge_record_management()
    history_management()
    vocab_management()
    user_management()
    show_hide_deleted()
    update_arch_ent_or_rel()
    autosave_entity_attributes()
    setup_attribute_groups()
    datatables_setup()
    setup_server_updates()
    return
)
