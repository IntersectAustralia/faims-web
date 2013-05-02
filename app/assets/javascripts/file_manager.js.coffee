show_file_submit_modal_dialog = ->
  $('.upload-container .upload-submit-btn').click(
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

$(document).ready =>
  show_file_submit_modal_dialog()
  $('.upload-container .file-upload-form').hide()
  $('.upload-container .upload-btn').click(
    ->
      container = $(this).parent('.upload-container')
      $('.upload-container .upload-btn').show()
      $('.upload-container .file-upload-form').hide()
      container.find('.upload-btn').hide()
      container.find('.file-upload-form').show()
      return false
  )
  $('.upload-container .upload-cancel-btn').click(
    ->
      container = $(this).parent('.upload-container')
      $('.upload-container .upload-btn').show()
      $('.upload-container .file-upload-form').hide()
      return false
  )
  $('.create-container .create-dir-form').hide()
  $('.create-container .create-btn').click(
    ->
      container = $(this).parent('.create-container')
      $('.create-container .create-btn').show()
      $('.create-container .create-dir-form').hide()
      container.find('.create-btn').hide()
      container.find('.create-dir-form').show()
      return false
  )
  $('.create-container .create-cancel-btn').click(
    ->
      container = $(this).parent('.create-container')
      $('.create-container .create-btn').show()
      $('.create-container .create-dir-form').hide()
      return false
  )