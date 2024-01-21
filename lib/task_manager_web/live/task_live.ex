defmodule TaskManagerWeb.TaskLive do
  use TaskManagerWeb, :live_view

  alias TaskManager.Tasks
  alias TaskManager.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    tasks = Tasks.list_tasks()

    socket
    |> assign(:form, to_form(Tasks.change_task(%Task{})))
    |> stream(:tasks, tasks)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validate" phx-submit="save" class="flex inline-block">
      <.input field={@form[:title]} placeholder="Title" autocomplete="off" phx-debounce="blur" />
      <.button phx-disable-with="Saving...">
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
    <div id={@dom_id} class="flex py-2 w-full text-xl justify-between">
      <div class="flex items-center gap-2">
        <input
          type="checkbox"
          checked={@task.status == :closed}
          phx-value-id={@task.id}
          phx-click="toggle-status"
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0 hover:cursor-pointer"
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
      {:ok, task} ->
        socket
        |> assign(:form, to_form(Tasks.change_task(%Task{})))
        |> stream_insert(:tasks, task, at: 0)
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  @impl true
  def handle_event("toggle-status", %{"id" => id}, socket) do
    {:ok, task} =
      id
      |> Tasks.get_task!()
      |> Tasks.toggle_task_status()

    socket
    |> stream_insert(:tasks, task)
    |> noreply()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, task} =
      id
      |> Tasks.get_task!()
      |> Tasks.delete_task()

    socket
    |> stream_delete(:tasks, task)
    |> noreply()
  end
end
