defmodule PollApp.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "poll" do
    field :question, :string
    field :created_by, :string
    field :time, :naive_datetime
    field :voters, {:array, :string}, default: []
    field :total_votes, :integer, default: 0

    embeds_many :options, Option, on_replace: :delete do
      field :text, :string
      field :votes, :integer, default: 0
    end
  end

  def changeset(poll, params \\ %{}) do
    poll
    |> cast(params, [:question, :created_by, :total_votes])
    |> validate_required([:question])
    |> cast_embed(:options, with: &option_changeset/2)
    |> maybe_put_id()
    |> put_change(:time, NaiveDateTime.utc_now())
  end

  def option_changeset(option, params \\ %{}) do
    option
    |> cast(params, [:text, :votes])
    |> validate_required([:text])
    |> maybe_put_id()
  end

  defp maybe_put_id(changeset) do
    if get_field(changeset, :id) do
      changeset
    else
      put_change(changeset, :id, UUID.uuid4(:hex))
    end
  end
end
