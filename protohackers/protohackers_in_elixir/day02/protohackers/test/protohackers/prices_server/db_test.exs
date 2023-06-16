defmodule Protohackets.PricesServer.DbTest do

  use ExUnit.Case

  alias Protohackers.PricesServer.Db

  test "adding elements and getting the average" do
    db = Db.new()

    assert Db.query(db, 0, 100 ) == 0

    db =
      db
      |> Db.add(1, 10)
      |> Db.add(2, 20)
      |> Db.add(3, 30)

    assert Db.query(db, 0, 100) == 20
    assert Db.query(db, 0, 2) == 15
    assert Db.query(db, 2, 3) == 25
    assert Db.query(db, 4, 100) == 0
  end

end
