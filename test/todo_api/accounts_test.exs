defmodule TodoApi.AccountsTest do
  use TodoApi.DataCase, async: true

  alias TodoApi.Accounts

  describe "users" do
    alias TodoApi.Accounts.User

    import TodoApi.AccountsFixtures

    @invalid_attrs %{username: 1234, password: 5678}

    setup do
      user = user_fixture()

      %{user: user}
    end

    test "list_users/0 returns all users", %{user: user} do
      # user = user_fixture()
      assert [%User{id: id}] = Accounts.list_users()
      assert user.id == id
    end

    test "does not return the user if the username does not exist" do
      refute Accounts.get_user_by_username("unknown")
    end

    test "returns the user if the username exists", %{user: %User{id: id} = user} do
      assert %User{id: ^id} = Accounts.get_user_by_username(user.username)
    end

    test "get_user/1 returns the user with given id", %{user: %User{username: username} = user} do
      assert %User{username: ^username} = Accounts.get_user(user.id)
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{username: "someUsername", password: "somePassword1"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.username == "someUsername"
      assert true == Argon2.verify_pass("somePassword1", user.hashed_password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user", %{user: user} do
      update_attrs = %{
        username: "someUpdatedUsername",
        password: "someUpdatedPassword1"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.username == "someUpdatedUsername"
      assert true == Argon2.verify_pass("someUpdatedPassword1", user.hashed_password)
    end

    test "update_user/2 with invalid data returns error changeset", %{user: old_user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(old_user, @invalid_attrs)
    end

    test "update_user/2 with invalid username format returns error changeset", %{user: old_user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(old_user, %{"username" => "hi"})
    end

    test "update_user/2 with invalid password format returns error changeset", %{user: old_user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(old_user, %{"password" => "password"})
    end

    test "delete_user/1 deletes the user", %{user: user} do
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(user.id)
    end

    test "change_user/1 returns a user changeset", %{user: user} do
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
