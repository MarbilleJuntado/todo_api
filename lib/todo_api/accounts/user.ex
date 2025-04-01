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
    |> validate_username()
    |> validate_password()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_username()
    |> validate_password()
  end

  defp validate_username(changeset) do
    username = get_change(changeset, :username)

    if changeset.valid? and not is_nil(username) do
      changeset
      |> validate_length(:username, min: 5, max: 30)
      |> validate_format(:username, ~r/^\w+$/,
        message: "can only contain letters, numbers, and underscores"
      )
      |> unique_constraint(:username)
    else
      changeset
    end
  end

  defp validate_password(changeset) do
    password = get_change(changeset, :password)

    if changeset.valid? and not is_nil(password) do
      changeset
      |> validate_length(:password, min: 6, max: 72)
      |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
      |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
      |> validate_format(:password, ~r/[0-9]/, message: "at least one number")
      |> put_hashed_password()
    else
      changeset
    end
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
