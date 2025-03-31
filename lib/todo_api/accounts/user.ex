defmodule TodoApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :hashed_password, :string

    has_many :tasks, TodoApi.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :hashed_password])
    |> validate_required([:username, :hashed_password])
    |> unique_constraint(:username)
    |> put_hashed_password()
  end

  defp put_hashed_password(
         %Ecto.Changeset{valid?: true, changes: %{hashed_password: hashed_password}} = changeset
       ) do
    change(changeset, hashed_password: Argon2.hash_pwd_salt(hashed_password))
  end

  defp put_hashed_password(changeset), do: changeset
end
