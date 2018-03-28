defmodule CodeFund.Schema.Property do
  use CodeFundWeb, :schema_with_formex

  @property_types %{
    website: 1,
    repository: 2,
    newsletter: 3
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    has_many :impressions, CodeFund.Schema.Impression
    has_many :clicks, CodeFund.Schema.Click
    belongs_to :sponsorship, CodeFund.Schema.Sponsorship
    belongs_to :user, CodeFund.Schema.User
    
    field :legacy_id, :string # This is used to tranfer legacy sponsored projects to the new system
    field :description, :string
    field :name, :string
    field :property_type, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(%Property{} = property, %{user: user} = params) do
    property
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> put_assoc(:user, user)
    |> validate_required(~w(name url property_type)a)
  end

  def changeset(%Property{} = property, params) do
    property
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(user_id name url property_type)a)
  end

  def property_types, do: @property_types
end
