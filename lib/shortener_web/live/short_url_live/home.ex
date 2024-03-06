defmodule ShortenerWeb.ShortUrlLive.Home do
  use ShortenerWeb, :live_view

  alias Shortener.Urls

  @impl true
  def mount(_params, _session, socket) do
    case socket.assigns[:current_user] do
      nil ->
        {:ok, socket}

      user ->
        urls =
          Urls.list_user_urls(user)

        {:ok,
         socket
         |> stream(:urls, urls)
         |> assign(:num_of_urls, length(urls))}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :home, _params) do
    socket
    |> assign(:page_title, "Shorten your URL")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    short_url = Urls.get_short_url!(id)

    changeset =
      short_url
      |> Urls.change_short_url()

    socket
    |> assign(:page_title, "Short URL")
    |> assign(:url_to_edit, short_url)
    |> assign_form(changeset)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    socket
    |> assign(:edit_form, to_form(changeset))
  end

  def make_full_url(slug) do
    "#{ShortenerWeb.Endpoint.url()}/#{slug}"
  end

  def remove_http_prefix(url) do
    Regex.replace(~r/^(http:\/\/|https:\/\/)/, url, "")
  end

  def minify_url(string, max_length \\ 37) do
    if String.length(string) > max_length do
      String.slice(string, 0..(max_length - 1)) <> "..."
    else
      string
    end
    |> remove_http_prefix()
  end

  @impl true
  def handle_event("shorten", %{"target_url" => target}, socket) do
    current_user = socket.assigns[:current_user]

    case Urls.create_short_url(target, current_user) do
      {:ok, short_url} ->
        socket =
          if current_user do
            socket
            |> stream_insert(:urls, short_url, at: 0)
            |> assign(:num_of_urls, socket.assigns.num_of_urls + 1)
          else
            socket
          end

        {:noreply,
         socket
         |> assign(:last_url, make_full_url(short_url.slug))
         |> assign(:target_url, target)}

      {:error, %Ecto.Changeset{errors: [target: _]}} ->
        {:noreply,
         socket
         |> put_flash(:error, "Your have entered an invalid URL")}
    end
  end

  @impl true
  def handle_event("validate_edit", %{"short_url" => short_url_params}, socket) do
    changeset =
      socket.assigns.url_to_edit
      |> Urls.change_short_url(short_url_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"short_url" => short_url_params}, socket) do
    if socket.assigns[:current_user] &&
         socket.assigns.url_to_edit.owner_id == socket.assigns[:current_user].id do
      case Urls.update_short_url(socket.assigns.url_to_edit, short_url_params) do
        {:ok, short_url} ->
          {:noreply,
           socket
           |> put_flash(:info, "Slug has been successfully updated to \"#{short_url.slug}\"")
           |> stream_insert(:urls, short_url)
           |> push_patch(to: ~p"/")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    else
      {:noreply, socket |> put_flash(:error, "You are not authorized to edit this URL")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    short_url = Urls.get_short_url!(id)

    if socket.assigns[:current_user] && short_url.owner_id == socket.assigns[:current_user].id do
      {:ok, _} = Urls.delete_short_url(short_url)

      {:noreply,
       socket
       |> stream_delete(:urls, short_url)
       |> assign(:num_of_urls, socket.assigns.num_of_urls - 1)}
    else
      {:noreply, socket |> put_flash(:error, "You are not authorized to delete this URL")}
    end
  end

  @impl true
  def handle_event("url-copied", _, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Short URL is copied to clipboard")}
  end
end
