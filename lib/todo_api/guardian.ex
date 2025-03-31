defmodule TodoApi.Guardian do
  use Guardian, otp_app: :todo_api

  alias TodoApi.Accounts
  alias TodoApi.Accounts.User

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      %User{} = user -> {:ok, user}
      _ -> {:error, :resource_not_found}
    end
  end
end
