defmodule CodeSponsor.Stats.Clicks do
  import Ecto.Query, warn: false
  alias CodeSponsor.Repo
  alias CodeSponsor.Schema.Property
  alias CodeSponsor.Schema.Campaign
  alias CodeSponsor.Schema.Sponsorship
  alias CodeSponsor.Schema.Click
  alias CodeSponsor.Schema.Impression
  alias CodeSponsor.Schema.User

  def with_sponsorship_details(nil, params), do: params

  def with_sponsorship_details(%CodeSponsor.Schema.Sponsorship{campaign_id: campaign_id, id: id}, params) do
    params
    |> Map.merge(%{
      campaign_id:    campaign_id,
      sponsorship_id: id,
    })
  end

  def count(start_date, end_date) when start_date <= end_date do
    Repo.one(
      from c in Click,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      select: fragment("count(*)")
    )
  end

  def count(%Property{} = property, start_date, end_date) when start_date <= end_date do
    Repo.one(
      from c in Click,
      where: c.property_id == ^property.id,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      select: fragment("count(*)")
    )
  end

  def count(%Sponsorship{} = sponsorship, start_date, end_date) when start_date <= end_date do
    Repo.one(
      from c in Click,
      where: c.sponsorship_id == ^sponsorship.id,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      select: fragment("count(*)")
    )
  end

  def count(%Campaign{} = campaign, start_date, end_date) when start_date <= end_date do
    Repo.one(
      from c in Click,
      where: c.campaign_id == ^campaign.id,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      select: fragment("count(*)")
    )
  end

  def count(%User{} = user, start_date, end_date) when start_date <= end_date do
    campaign_ids =
      Repo.all(from c in Campaign, where: c.user_id == ^user.id)
      |> Enum.map(fn (c) -> c.id end)

    property_ids =
      Repo.all(from p in Property, where: p.user_id == ^user.id)
      |> Enum.map(fn (c) -> c.id end)

    Repo.one(
      from c in Click,
      where: c.campaign_id in ^campaign_ids or c.property_id in ^property_ids,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      select: fragment("count(*)")
    )
  end

  def count_by_day(start_date, end_date) when start_date <= end_date do
    (
      from c in Click,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      group_by: fragment("date_trunc('day', ?)", (field(c, ^:inserted_at))),
      select: [(fragment("date_trunc('day', ?)", (field(c, ^:inserted_at)))), count("*")]
    ) |> to_date_map()
  end

  def count_by_day(%Property{} = property, start_date, end_date) when start_date <= end_date do
    (
      from c in Click,
      where: c.property_id == ^property.id,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      group_by: fragment("date_trunc('day', ?)", (field(c, ^:inserted_at))),
      select: [(fragment("date_trunc('day', ?)", (field(c, ^:inserted_at)))), count("*")]
    ) |> to_date_map()
  end

  def count_by_day(%Sponsorship{} = sponsorship, start_date, end_date) when start_date <= end_date do
    (
      from c in Click,
      where: c.sponsorship_id == ^sponsorship.id,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      group_by: fragment("date_trunc('day', ?)", (field(c, ^:inserted_at))),
      select: [(fragment("date_trunc('day', ?)", (field(c, ^:inserted_at)))), count("*")]
    ) |> to_date_map()
  end

  def count_by_day(%Campaign{} = campaign, start_date, end_date) when start_date <= end_date do
    (
      from c in Click,
      where: c.campaign_id == ^campaign.id,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      group_by: fragment("date_trunc('day', ?)", (field(c, ^:inserted_at))),
      select: [(fragment("date_trunc('day', ?)", (field(c, ^:inserted_at)))), count("*")]
    ) |> to_date_map()
  end

  def count_by_day(%Campaign{} = campaign, start_date, end_date) when start_date <= end_date do
    (
      from i in Impression,
      where: i.campaign_id == ^campaign.id,
      where: fragment("?::date", i.inserted_at) >= ^start_date,
      where: fragment("?::date", i.inserted_at) <= ^end_date,
      group_by: fragment("date_trunc('day', ?)", (field(i, ^:inserted_at))),
      select: [(fragment("date_trunc('day', ?)", (field(i, ^:inserted_at)))), count("*")]
    ) |> to_date_map()
  end

  def count_by_day(%User{} = user, start_date, end_date) when start_date <= end_date do
    campaign_ids =
      Repo.all(from c in Campaign, where: c.user_id == ^user.id)
      |> Enum.map(fn (c) -> c.id end)

    property_ids =
      Repo.all(from p in Property, where: p.user_id == ^user.id)
      |> Enum.map(fn (c) -> c.id end)

    (
      from c in Click,
      where: c.campaign_id in ^campaign_ids or c.property_id in ^property_ids,
      where: fragment("?::date", c.inserted_at) >= ^start_date,
      where: fragment("?::date", c.inserted_at) <= ^end_date,
      group_by: fragment("date_trunc('day', ?)", (field(c, ^:inserted_at))),
      select: [(fragment("date_trunc('day', ?)", (field(c, ^:inserted_at)))), count("*")]
    ) |> to_date_map()
  end

  defp to_date_map(query) do
    query
    |> Repo.all
    |> Enum.map(fn([day, count]) ->
      {:ok, date} =
        day
        |> Tuple.delete_at(1)
        |> Tuple.insert_at(1, {0, 0, 0})
        |> NaiveDateTime.from_erl()

      formatted_date = Timex.format!(date, "%F", :strftime)
      {formatted_date, count}
    end)
    |> Enum.into(%{})
  end
end