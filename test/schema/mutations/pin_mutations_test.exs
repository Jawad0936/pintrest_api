defmodule PinterestApiWeb.Schema.Mutations.PinMutationsTest do
  use PinterestApiWeb.SchemaCase

  import PinterestApi.Factory

  describe "createPin" do
    test "creates a pin when authenticated" do
      user = insert_user()

      mutation = """
      mutation {
        createPin(input: { description: "New pin", category: "learning" }) {
          pin { id description category status }
          errors { field message }
        }
      }
      """

      assert {:ok, %{data: %{"createPin" => result}}} = run_query(mutation, current_user: user)
      assert result["errors"] == nil
      assert result["pin"]["description"] == "New pin"
      assert result["pin"]["status"] == "PENDING"
    end

    test "returns validation errors for missing fields" do
      user = insert_user()

      mutation = """
      mutation {
        createPin(input: { description: "", category: "learning" }) {
          pin { id }
          errors { field message }
        }
      }
      """

      assert {:ok, %{data: %{"createPin" => result}}} = run_query(mutation, current_user: user)
      assert result["pin"] == nil
      assert result["errors"] != nil
    end

    test "requires authentication" do
      mutation = """
      mutation {
        createPin(input: { description: "New pin", category: "learning" }) {
          pin { id }
        }
      }
      """

      assert {:ok, %{errors: errors}} = run_query(mutation)
      assert Enum.any?(errors, &(&1.message == "Not authenticated"))
    end
  end

  describe "completePin" do
    test "marks a pin as completed" do
      user = insert_user()
      pin = insert_pin(%{user: user, status: "pending"})

      mutation = """
      mutation {
        completePin(id: "#{pin.id}") {
          pin { id status completedAt }
          errors { field message }
        }
      }
      """

      assert {:ok, %{data: %{"completePin" => result}}} = run_query(mutation, current_user: user)
      assert result["pin"]["status"] == "COMPLETED"
      assert result["pin"]["completedAt"] != nil
    end

    test "denies completing another user's pin" do
      owner = insert_user()
      other_user = insert_user()
      pin = insert_pin(%{user: owner})

      mutation = """
      mutation {
        completePin(id: "#{pin.id}") { pin { id } errors { message } }
      }
      """

      assert {:ok, %{data: %{"completePin" => result}}} =
               run_query(mutation, current_user: other_user)

      assert result["pin"] == nil
      assert Enum.any?(result["errors"], &(&1["message"] == "Not authorized"))
    end
  end

  describe "deletePin" do
    test "deletes a pin owned by the current user" do
      user = insert_user()
      pin = insert_pin(%{user: user})

      mutation = """
      mutation {
        deletePin(id: "#{pin.id}") { success errors { message } }
      }
      """

      assert {:ok, %{data: %{"deletePin" => result}}} = run_query(mutation, current_user: user)
      assert result["success"] == true
      assert Repo.get(PinterestApi.Pins.Pin, pin.id) == nil
    end
  end

  describe "createLog" do
    test "adds a log entry to a pin" do
      user = insert_user()
      pin = insert_pin(%{user: user})

      mutation = """
      mutation {
        createLog(pinId: "#{pin.id}", description: "Progress update") {
          log { id description }
          errors { field message }
        }
      }
      """

      assert {:ok, %{data: %{"createLog" => result}}} = run_query(mutation, current_user: user)
      assert result["log"]["description"] == "Progress update"
    end
  end
end
