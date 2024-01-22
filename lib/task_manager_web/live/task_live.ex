defmodule TaskManagerWeb.TaskLive do
  use TaskManagerWeb, :live_view

  alias TaskManager.Tasks
  alias TaskManager.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Tasks.subscribe()

    tasks = Tasks.list_tasks()

    socket
    |> assign(:form, to_form(Tasks.change_task(%Task{})))
    |> stream(:tasks, tasks)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validate" phx-submit="save" class="join w-full">
      <.input
        field={@form[:title]}
        placeholder="Title"
        autocomplete="off"
        phx-debounce="200"
        class="join-item w-full"
      />
      <.button phx-disable-with="Saving..." class="btn btn-neutral join-item">
        Create
      </.button>
    </.form>
    <div id="tasks" phx-update="stream" class="mt-8">
      <.task :for={{dom_id, task} <- @streams.tasks} dom_id={dom_id} task={task} />
    </div>
    """
  end

  attr :task, Task, required: true
  attr :dom_id, :integer, required: true

  def task(assigns) do
    ~H"""
    <div id={@dom_id} class="flex py-2 w-full justify-between">
      <div class="flex items-center gap-2">
        <input
          type="checkbox"
          checked={@task.status == :closed}
          phx-value-id={@task.id}
          phx-click="toggle-status"
          class="checkbox"
        />
        <p class={if @task.status == :closed, do: "line-through"}>
          <%= @task.title %>
        </p>
      </div>
      <.link phx-click="delete" phx-value-id={@task.id} class="hover:text-red-600">
        <.icon name="hero-trash" />
      </.link>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"task" => task}, socket) do
    changeset =
      %Task{}
      |> Tasks.change_task(task)
      |> Map.put(:action, :validate)

    socket
    |> assign(:form, to_form(changeset))
    |> noreply()
  end

  @impl true
  def handle_event("save", %{"task" => task}, socket) do
    case Tasks.create_task(task) do
      {:ok, _task} ->
        socket
        |> assign(:form, to_form(Tasks.change_task(%Task{})))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  @impl true
  def handle_event("toggle-status", %{"id" => id}, socket) do
    {:ok, _task} =
      id
      |> Tasks.get_task!()
      |> Tasks.toggle_task_status()

    noreply(socket)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _task} =
      id
      |> Tasks.get_task!()
      |> Tasks.delete_task()

    noreply(socket)
  end

  @impl true
  def handle_info({:task_created, task}, socket) do
    socket
    |> stream_insert(:tasks, task, at: 0)
    |> noreply()
  end

  @impl true
  def handle_info({:task_updated, task}, socket) do
    socket
    |> stream_insert(:tasks, task)
    |> noreply()
  end

  @impl true
  def handle_info({:task_deleted, task}, socket) do
    socket
    |> stream_delete(:tasks, task)
    |> noreply()
  end
end
