# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready(
  =>
    $('.project-submit-btn').each(
      =>
        $('.project-submit-btn').click(
          =>
            $('#project-form').submit()
            return false
        )
    )
    $('.data-schema-upload-btn').each(
      =>
        $('.data-schema-upload-btn').click(
          =>
            options = {
              dataType: 'json',
              success: (data) =>
                $('#data-schema-form').parent().find('.help-inline').remove()
                if data.status == 'success'
                  $('#data-schema-form').replaceWith("<span class='file-uploaded'>File Uploaded!</span>")
                else
                  $('#data-schema-form').parent().append("<span class='help-inline'>"+ data.message + "</span>")
              ,
              #error: => alert('error')
            }
            $('#data-schema-form').ajaxSubmit(options)
            return false
        )
    )
    $('.ui-schema-upload-btn').each(
      =>
        $('.ui-schema-upload-btn').click(
          =>
            options = {
              dataType: 'json',
              success: (data) =>
                $('#ui-schema-form').parent().find('.help-inline').remove()
                if data.status == 'success'
                  $('#ui-schema-form').replaceWith("<span class='file-uploaded'>File Uploaded!</span>")
                else
                  $('#ui-schema-form').parent().append("<span class='help-inline'>"+ data.message + "</span>")
              ,
              #error: => alert('error')
            }
            $('#ui-schema-form').ajaxSubmit(options)
            return false
        )
    )
)


