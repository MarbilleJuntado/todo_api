defmodule TodoApiWeb.InfoControllerTest do
  use TodoApiWeb.ConnCase, async: true

  describe "InfoController" do
    test "Info - valid" do
      conn =
        build_conn()
        |> put_req_header("accept", "application/json")

      conn = get(conn, ~p"/api/info")

      assert %{"version" => _version} = json_response(conn, 200)
    end
  end
end
