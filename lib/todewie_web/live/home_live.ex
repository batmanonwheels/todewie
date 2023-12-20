defmodule TodewieWeb.HomeLive do
  use TodewieWeb, :live_view

  alias Todewie.Todews
  alias Todewie.Todews.Todew

  @impl true
  def render(%{loading: true} = assigns) do
    ~H"""
    <h1 class='text-2xl '>Todewie is loading...</h1>
    """
  end

  def render(assigns) do
    ~H"""
      <h1 class='text-2xl '>Todewie</h1>
      <.button type="button" phx-click={show_modal("new-todew-modal")} >Create Todew</.button>


      <h2 class='text-xl pt'>Latest Todews</h2>
      <div id="feed" phx_update="stream" class="flex flex-col gap-2 p-2">
        <div :for={{dom_id, todew} <- @streams.todews} id={dom_id} class="flex flex-col w-full gap-2 p-4 mx-auto border rounded-sm">
        <img src={todew.image} />
        <p><%=todew.user.email %></p>
        <p><%=todew.text %></p>
        </div>
      </div>

      <.modal id="new-todew-modal">
        <.simple_form for={@form} phx-change="validate" phx-submit="save-todew">
          <.input field={@form[:text]} type="textarea" label="What do you need todew?" required/>
          <.live_file_input upload={@uploads.image} />
          <.button type="submit" phx-disable-with="Creating Todew..">Create Todew</.button>
        </.simple_form>
      </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
    Phoenix.PubSub.subscribe(Todewie.PubSub, "todews")

    form =
      %Todew{}
      |> Todew.changeset(%{})
      |> to_form(as: "todew")

    socket =
      socket
      |> assign(form: form)
      |> allow_upload(:image, accept: ~w(.png .jpg), max_entries: 1)
      |> stream(:todews, Todews.list_posts())
    {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save-todew", %{"todew" => todew_params}, socket) do
    %{current_user: user} = socket.assigns

    todew_params
    |> Map.put("user_id", user.id)
    |> Map.put("image", List.first(consume_files(socket)))
    |> Todews.save()
    |> case do
      {:ok, todew} ->
          socket =
            socket
            |> put_flash(:info, "Todew created successfully!")
            |> push_navigate(to: ~p"/home")

          Phoenix.PubSub.broadcast(Todewie.PubSub, "todews", {:new, Map.put(todew, :user, user)})

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end

  end

  @impl true
  def handle_info({:new, todew}, socket) do
    socket =
      socket
      |> put_flash(:info, "#{todew.user.email} just created a new todew")
      |> stream_insert(:todews, todew,at: 0)
    {:noreply, socket}
  end

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      dest = Path.join([:code.priv_dir(:todewie), "static", "uploads",Path.basename(path)])
      File.cp!(path, dest)

      {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end
end
