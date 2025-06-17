defmodule LssfHtsWeb.Utils.TimeUtils do
  use Timex

  @format "{YYYY}-{0M}-{0D}T{h24}:{m}"

  def convert_local_to_utc!(%{"schedule" => schedule, "run_until" => run_until} = params, user_tz) do
    [schedule_utc, until_utc] =
      [schedule, run_until]
      |> Enum.map(fn time_str ->
        time_str
        |> Timex.parse!(@format)
        |> Timex.to_datetime(user_tz)
        |> Timex.Timezone.convert("UTC")
      end)

    params
    |> Map.put("schedule", schedule_utc)
    |> Map.put("run_until", until_utc)
  end

  def convert_utc_to_local_form(data, user_tz \\ "Europe/Brussels")
  def convert_utc_to_local_form(utc_time, user_tz) when is_struct(utc_time, DateTime) do
    Timex.Timezone.convert(utc_time, user_tz)
  end
  def convert_utc_to_local_form(%{schedule: schedule, run_until: run_until}, user_tz) do
    [schedule_local, until_local] =
      [schedule, run_until]
      |> Enum.map(&Timex.Timezone.convert(&1, user_tz))

    %{
      schedule: schedule_local,
      run_until: until_local
    }
  end

end
