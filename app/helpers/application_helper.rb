module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title }
  end

  # convenience method to render a field on a view screen - saves repeating the div/span etc each time
  def render_field(label, value)
    render_field_content(label, (h value))
  end

  def render_field_if_not_empty(label, value)
    render_field_content(label, (h value)) if value != nil && !value.empty?
  end

  # as above but takes a block for the field value
  def render_field_with_block(label, &block)
    content = with_output_buffer(&block)
    render_field_content(label, content)
  end

  def user_dropdown_menu
    "#{h current_user.full_name}<b class=\"caret\"></b>".html_safe
  end

  private
  def render_field_content(label, content)
    div_class = cycle("field_bg", "field_nobg")
    div_id = label.tr(" ,", "_").downcase
    html = "<div class='#{div_class} inlineblock' id='display_#{div_id}'>"
    html << '<span class="label_view">'
    html << (h label)
    html << ":"
    html << '</span>'
    html << '<span class="field_value">'
    html << content
    html << '</span>'
    html << '</div>'
    html.html_safe
  end

  def breadcrumbs
    return unless @crumbs
    return unless @page_crumbs
    html = '<ul class="breadcrumb">'
    @page_crumbs.each_with_index do |c, i|
      crumb = @crumbs[c]
      if i != @page_crumbs.size - 1
        html << "<li><a href=\"#{crumb[:url]}\">#{crumb[:title]}</a> <span class=\"divider\">/</span></li>"
      else
        html << "<li class=\"active\">#{crumb[:title]}</li>"
      end
    end
    html << '</ul>'
    html.html_safe
  end

end
