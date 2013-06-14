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

delete_arch_ent_members = ->
  $('input#remove-member').each(
    -> $(this).click(
      ->
        $.post $(this).attr('src')
        $(this).parent().remove()
        return
    )
  )
  return

search_arch_ent_members = ->
  $('#search-member').click(
    ->
      window.location = $(this).attr('src')
      return
  )
  return

add_arch_ent_member = ->
  $('#add-arch-ent').click(
    ->
      selected = $('input[type="radio"]:checked')
      verb = $('#verb').val()
      if selected.length == 0
        alert('No Archaeological Entity is selected to be added')
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

delete_records = ->
  $('#delete-record').one("click",
    ->
      $(this).click(
        =>
          return false
      )
      return
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

select_all_compared_attributes = ->
  $('#select-first').click(
    ->
      $('#select-form input:checkbox').each(
        ->
          $(this).prop('checked',false)
          li_sibling = $(this).parents('td').siblings()
          if(li_sibling.length)
            $(li_sibling).find('.step-body').removeClass('selected')
            return
          return
      )
      $('td.first input:checkbox').each(
        ->
          $(this).prop('checked',true)
          li_sibling = $(this).parents('li').siblings()
          if(li_sibling.length)
            $(li_sibling).find('.step-body').addClass('selected')
            return
          return
      )
  )
  $('#select-second').click(
    ->
      $('#select-form input:checkbox').each(
        ->
          $(this).prop('checked',false)
          li_sibling = $(this).parents('li').siblings()
          if(li_sibling.length)
            $(li_sibling).find('.step-body').removeClass('selected')
            return
          return
      )
      $('td.second input:checkbox').each(
        ->
          $(this).prop('checked',true)
          li_sibling = $(this).parents('li').siblings()
          if(li_sibling.length)
            $(li_sibling).find('.step-body').addClass('selected')
            return
          return
      )
  )
  return

change_checked_attributes = ->
  $('#select-form input:checkbox').change(
    ->
      siblings = $(this).parents('td').siblings()[0]
      $sibling_checkbox = $(siblings).find('input:checkbox')
      if($sibling_checkbox.length)
        if($(this).is(':checked'))
          if($sibling_checkbox.is(':checked'))
            $sibling_checkbox.prop('checked', false)
            li_sibling = $sibling_checkbox.parents('li').siblings()
            $(li_sibling).find('.step-body').removeClass('selected')
            li_sibling = $(this).parents('li').siblings()
            $(li_sibling).find('.step-body').addClass('selected')
            return
          return
        else
          if(!$sibling_checkbox.is(':checked'))
            $(this).prop('checked', true)
            return
          return
      else
        if(!$(this).is(':checked'))
          $(this).prop('checked', true)
          return
        return
  )
  return

merge_record = ->
  $('#merge-record').click(
    ->
      $form = $('<form method="post">')
      $form.attr('action',$(this).attr('href'))
      $('#select-form').find('input:checkbox:checked').each(
        ->
          li_sibling = $(this).parents('li').siblings()
          if(li_sibling.length)
            $(li_sibling).find('input').each(
              ->
                if $(this).attr('name') != undefined
                  $form.append(this)
                  return
                return
            )
            return
          else
            input_sibling = $(this).siblings('input')
            $form.append(this)
            if(input_sibling.length)
              $(input_sibling).each(
                ->
                  $form.append(this)
                  return
              )
              return

          return
      )
      $('body').append($form)
      $form.hide()
      $form.submit()
      false
  )
  return

$(document).ready(
  =>
    show_submit_modal_dialog()
    show_upload_modal_dialog()
    show_archive_modal_dialog()
    compare_records()
    compare_input_checked_handler()
    search_arch_ent_members()
    add_arch_ent_member()
    delete_arch_ent_members()
    delete_records()
    download_attached_file()
    select_all_compared_attributes()
    change_checked_attributes()
    merge_record()
    return
)