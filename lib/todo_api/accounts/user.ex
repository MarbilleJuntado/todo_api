defmodule TodoApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true

    has_many :tasks, TodoApi.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def register_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
    |> put_hashed_password()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> unique_constraint(:username)
    |> put_hashed_password()
  end

  defp put_hashed_password(changeset) do
    password = get_change(changeset, :password)

    if changeset.valid? and not is_nil(password) do
      change(changeset, hashed_password: Argon2.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
