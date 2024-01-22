defmodule TaskManager.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TaskManager.Repo

  alias TaskManager.Tasks.Task

  @topic inspect(__MODULE__)

  @doc """
  Subscribes to the tasks topic.
  """
  def subscribe() do
    Phoenix.PubSub.subscribe(TaskManager.PubSub, @topic)
  end

  defp broadcast({:ok, task} = result, tag) do
    Phoenix.PubSub.broadcast(TaskManager.PubSub, @topic, {tag, task})
    result
  end

  defp broadcast({:error, _changeset} = error, _tag), do: error

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(from t in Task, order_by: [desc: t.inserted_at])
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:task_created)
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
    |> broadcast(:task_updated)
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
    |> broadcast(:task_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def toggle_task_status(%Task{} = task) do
    update_task(task, %{status: task_next_status(task)})
  end

  defp task_next_status(%Task{status: :closed}), do: :open
  defp task_next_status(%Task{status: :open}), do: :closed
end
