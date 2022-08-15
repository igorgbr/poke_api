defmodule ExMonWeb.Controllers.TrainersControllerTest do
  use ExMonWeb.ConnCase
  import ExMonWeb.Auth.Guardian

  alias ExMon.Trainer

  describe "show/2" do
    setup %{conn: conn} do
      params = %{name: "igor", password: "123456"}

      {:ok, trainer} = ExMon.create_trainer(params)
      {:ok, token, _claims} = encode_and_sign(trainer)

      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn}
    end

    test "when there is a trainer, return the trainer", %{conn: conn} do
      params = %{name: "igor", password: "123456"}

      {:ok, %Trainer{id: id}} = ExMon.create_trainer(params)

      response =
        conn
        |> get(Routes.trainers_path(conn, :show, id))
        |> json_response(:ok)

      assert %{"id" => _id, "inserted_at" => _date, "name" => "igor"} = response
    end

    test "when there is an error, return the error", %{conn: conn} do
      response =
        conn
        |> get(Routes.trainers_path(conn, :show, 1))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid ID Format"}

      assert expected_response == response
    end
  end

  describe "create/2" do
    test "when create a trainer, return ok", %{conn: conn} do
      params = %{name: "igor", password: "123456"}

      response =
        conn
        |> post(Routes.trainers_path(conn, :create, params))
        |> json_response(201)

      assert %{"message" => "Trainer Created", "trainer" => _trainer} = response
    end

    test "when miss params, return an error", %{conn: conn} do
      params = %{password: "123456"}

      %{"message" => expected_response} =
        conn
        |> post(Routes.trainers_path(conn, :create, params))
        |> json_response(:bad_request)

      assert expected_response == %{"name" => ["can't be blank"]}
    end

    test "when miss all required params, return an error", %{conn: conn} do
      %{"message" => expected_response} =
        conn
        |> post(Routes.trainers_path(conn, :create, %{}))
        |> json_response(:bad_request)

      assert expected_response == %{
               "name" => ["can't be blank"],
               "password" => ["can't be blank"]
             }
    end
  end

  describe "delete/2" do
    setup %{conn: conn} do
      params = %{name: "igor", password: "123456"}

      {:ok, trainer} = ExMon.create_trainer(params)
      {:ok, token, _claims} = encode_and_sign(trainer)

      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn}
    end

    test "when delete a trainer, return ok", %{conn: conn} do
      params = %{name: "igor", password: "123456"}

      {:ok, %Trainer{id: id}} = ExMon.create_trainer(params)

      assert %{status: 204} = conn |> delete(Routes.trainers_path(conn, :delete, id))
    end

    test "when delete a trainer without exist, return error", %{conn: conn} do
      assert %{status: 400} = conn |> delete(Routes.trainers_path(conn, :delete, 1))
    end
  end

  describe "update/2" do
    setup %{conn: conn} do
      params = %{name: "igor", password: "123456"}

      {:ok, trainer} = ExMon.create_trainer(params)
      {:ok, token, _claims} = encode_and_sign(trainer)

      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn}
    end

    test "when update a trainer, return a trainer", %{conn: conn} do
      params = %{name: "igor", password: "123456"}

      {:ok, %Trainer{id: id}} = ExMon.create_trainer(params)

      new_params = %{name: "Gabriel", password: "123456"}

      %{"message" => response} =
        conn
        |> put(Routes.trainers_path(conn, :update, id), new_params)
        |> json_response(:ok)

      assert response == "Trainer Updated"
    end
  end
end
