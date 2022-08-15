defmodule ExMon.Trainer.CreateTest do
  use ExMon.DataCase

  alias ExMon.{Repo, Trainer}
  alias ExMon.Trainer.Create

  describe "call/1" do
    test "Create trainer with all paramater is valid" do
      params = %{name: "Joaquim", password: "123456"}

      count_before = Repo.aggregate(Trainer, :count)

      response = Create.call(params)

      count_after = Repo.aggregate(Trainer, :count)

      assert {:ok, %Trainer{name: "Joaquim"}} = response
      assert count_after > count_before
    end

    test "With param is invalid, return error" do
      params = %{name: "Joaquim"}

      response = Create.call(params)

      assert {:error, changeset} = response
      assert errors_on(changeset) == %{password: ["can't be blank"]}
    end
  end
end
