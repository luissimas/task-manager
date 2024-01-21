defmodule TaskManager.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :position, :integer, default: 0
    field :status, Ecto.Enum, values: [:open, :closed], default: :open
    field :description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :position, :status])
    |> validate_required([:title, :position, :status])
    |> validate_length(:title, min: 2)
  end
end
