defmodule ExMon.Trainer.Pokemon do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExMon.Trainer
  alias ExMon.Repo

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "pokemons" do
    field :name, :string
    field :nickname, :string
    field :weight, :integer
    field :types, {:array, :string}
    belongs_to(:trainer, Trainer)
    timestamps()
  end

  @required [:name, :nickname, :weight, :types, :trainer_id]

  def build(params) do
    params
    |> verify_trainer_id()

    # |> changeset()
    # |> apply_action(:insert)
  end

  defp verify_trainer_id(%{trainer_id: trainer_id} = params) do
    case Repo.get(Trainer, trainer_id) do
      nil -> {:error, "Trainer id invalid!"}
      _ -> create_changeset(params)
    end
  end

  defp create_changeset(trainer) do
    trainer
    |> changeset()
    |> apply_action(:insert)
  end

  @spec changeset(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          Ecto.Changeset.t()
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:nickname, min: 2)
  end

  def update_changeset(pokemon, params) do
    pokemon
    |> cast(params, [:nickname])
    |> validate_required(:nickname)
    |> validate_length(:nickname, min: 2)
  end
end
