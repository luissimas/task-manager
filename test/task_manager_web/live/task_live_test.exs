defmodule TaskManagerWeb.TaskLiveTest do
  use TaskManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TaskManager.TasksFixtures

  test "renders page with form and task list", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/tasks")

    assert has_element?(view, "div#tasks")
    assert has_element?(view, "form#task-form")
  end

  test "user can create a task", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/tasks")

    task_title = "Task title"

    view
    |> form("#task-form", task: %{title: task_title})
    |> render_submit()

    assert has_element?(view, "#tasks span", task_title)
  end

  test "user can mark task as completed", %{conn: conn} do
    task_title = "Task title"
    task = task_fixture(%{title: task_title})
    {:ok, view, _html} = live(conn, "/tasks")

    view
    |> element("#tasks-#{task.id} input[type=checkbox]")
    |> render_click()

    assert has_element?(view, "#tasks-#{task.id} s", task_title)
  end

  test "user can delete a task", %{conn: conn} do
    task_title = "Task title"
    task = task_fixture(%{title: task_title})
    {:ok, view, _html} = live(conn, "/tasks")

    view
    |> element("#tasks-#{task.id} #delete-task")
    |> render_click()

    assert not has_element?(view, "#tasks-#{task.id}", task_title)
  end
end
