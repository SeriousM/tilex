defmodule Tilex.Developer do
  use TilexWeb, :model

  @type t :: module

  alias Tilex.{Developer, Post}

  schema "developers" do
    field(:email, :string)
    field(:username, :string)
    field(:twitter_handle, :string)
    field(:admin, :boolean)
    field(:editor, :string)

    has_many(:posts, Post)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :username, :twitter_handle, :editor])
    |> validate_required([:email, :username])
  end

  def find_or_create(repo, attrs) do
    email = Map.get(attrs, :email)

    case repo.get_by(Developer, email: email) do
      %Developer{} = developer ->
        {:ok, developer}

      _ ->
        %Developer{}
        |> changeset(attrs)
        |> repo.insert()
    end
  end

  def format_username(name) when is_binary(name) do
    name
    |> String.downcase()
    |> String.replace(" ", "")
  end

  defimpl Phoenix.Param, for: Developer do
    def to_param(%{username: username}) do
      username
    end
  end
end
