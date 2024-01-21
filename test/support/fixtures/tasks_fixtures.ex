defmodule TaskManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        position: 42,
        status: :open,
        title: "some title"
      })
      |> TaskManager.Tasks.create_task()

    task
  end
end
