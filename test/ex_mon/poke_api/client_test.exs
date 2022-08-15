defmodule ExMon.PokeApi.ClientTest do
  use ExUnit.Case

  import Tesla.Mock
  alias ExMon.PokeApi.Client

  @base_url "https://pokeapi.co/api/v2/pokemon"
  describe "get pokemon/1" do
    test "when there is a pokemon, return the pokemon" do
      body = %{"name" => "pikachu", "weight" => 60, "types" => ["eletric"]}

      mock(fn %{method: :get, url: @base_url <> "/pikachu"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      response = Client.get_pokemon("pikachu")

      expected_reponse = {:ok, %{"name" => "pikachu", "weight" => 60, "types" => ["eletric"]}}

      assert expected_reponse == response
    end

    test "when there no pokemon, return an error" do
      mock(fn %{method: :get, url: @base_url <> "/xablau"} ->
        %Tesla.Env{status: 404}
      end)

      response = Client.get_pokemon("xablau")

      expected_reponse = {:error, 404, nil}

      assert expected_reponse == response
    end

    test "when there unexpected error, return an error" do
      mock(fn %{method: :get, url: @base_url <> "/pikachu"} ->
        {:error, :timeout}
      end)

      response = Client.get_pokemon("pikachu")

      expected_reponse = {:error, :timeout}

      assert expected_reponse == response
    end
  end
end
