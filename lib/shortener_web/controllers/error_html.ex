defmodule ShortenerWeb.ErrorHTML do
  use ShortenerWeb, :html

  embed_templates "error_html/404.*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
