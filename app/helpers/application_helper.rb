# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Adds stylesheets
  def stylesheet(*names)
    content_for :additional_styles do
      stylesheet_link_tag *names
    end
  end

  # Adds javascript files
  def javascript(*names)
    content_for :additional_scripts do
      javascript_include_tag *names
    end
  end
end
