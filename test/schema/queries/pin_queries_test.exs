defmodule PinterestApiWeb.Schema.Queries.PinQueriesTest do
  use PinterestApiWeb.SchemaCase

  import PinterestApi.Factory

  describe "me" do
    test "returns current user when authenticated" do
      user = insert_user(%{name: "Jojo", email: "jojo@example.com"})

      query = """
      { me { id name email } }
      """

      assert {:ok, %{data: %{"me" => result}}} = run_query(query, current_user: user)
      assert result["name"] == "Jojo"
      assert result["email"] == "jojo@example.com"
    end

    test "returns nil when not authenticated" do
      query = """
      { me { id name email } }
      """

      assert {:ok, %{data: %{"me" => nil}}} = run_query(query)
    end
  end

  describe "pins" do
    test "returns paginated pins for current user" do
      user = insert_user()
      insert_pin(%{user: user, description: "Pin 1"})
      insert_pin(%{user: user, description: "Pin 2"})

      query = """
      {
        pins(first: 10) {
          edges { node { id description } cursor }
          pageInfo { hasNextPage endCursor }
        }
      }
      """

      assert {:ok, %{data: %{"pins" => result}}} = run_query(query, current_user: user)
      assert length(result["edges"]) == 2
      assert result["pageInfo"]["hasNextPage"] == false
    end

    test "filters by status" do
      user = insert_user()
      insert_pin(%{user: user, status: "pending"})
      insert_pin(%{user: user, status: "completed"})

      query = """
      {
        pins(status: PENDING, first: 10) {
          edges { node { status } }
        }
      }
      """

      assert {:ok, %{data: %{"pins" => result}}} = run_query(query, current_user: user)
      assert length(result["edges"]) == 1
      assert hd(result["edges"])["node"]["status"] == "PENDING"
    end

    test "requires authentication" do
      query = """
      { pins(first: 10) { edges { node { id } } } }
      """

      assert {:ok, %{errors: errors}} = run_query(query)
      assert Enum.any?(errors, &(&1.message == "Not authenticated"))
    end

    test "respects pagination cursor" do
      user = insert_user()
      insert_pin(%{user: user, description: "First"})
      insert_pin(%{user: user, description: "Second"})

      first_page_query = """
      { pins(first: 1) { edges { cursor } pageInfo { hasNextPage endCursor } } }
      """

      assert {:ok, %{data: %{"pins" => first_page}}} =
               run_query(first_page_query, current_user: user)

      assert first_page["pageInfo"]["hasNextPage"] == true
      cursor = first_page["pageInfo"]["endCursor"]

      second_page_query = """
      { pins(first: 1, after: "#{cursor}") { edges { node { description } } pageInfo { hasNextPage } } }
      """

      assert {:ok, %{data: %{"pins" => second_page}}} =
               run_query(second_page_query, current_user: user)

      assert length(second_page["edges"]) == 1
      assert second_page["pageInfo"]["hasNextPage"] == false
    end
  end

  describe "pin" do
    test "returns a single pin by id" do
      user = insert_user()
      pin = insert_pin(%{user: user, description: "Specific pin"})

      query = """
      { pin(id: "#{pin.id}") { id description } }
      """

      assert {:ok, %{data: %{"pin" => result}}} = run_query(query, current_user: user)
      assert result["description"] == "Specific pin"
    end

    test "denies access to another user's pin" do
      owner = insert_user()
      other_user = insert_user()
      pin = insert_pin(%{user: owner})

      query = """
      { pin(id: "#{pin.id}") { id } }
      """

      assert {:ok, %{errors: errors}} = run_query(query, current_user: other_user)
      assert Enum.any?(errors, &(&1.message == "Not authorized"))
    end
  end
end
