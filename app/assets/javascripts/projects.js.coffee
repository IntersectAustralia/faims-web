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
            return false
        )
    )
    $('.ui-schema-upload-btn').each(
      =>
        $('.ui-schema-upload-btn').click(
          =>
            $('#ui-schema-form').submit()
            return false
        )
    )
)


