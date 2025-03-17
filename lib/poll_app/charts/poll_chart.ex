defmodule PollApp.Charts.PollChart do
  @moduledoc """
  Generates a bar chart for poll options and votes using Contex.

  The `generate_chart/1` function creates an SVG bar chart from a list of poll options.
  """
  alias Contex.{Plot, BarChart, Dataset}

  def generate_chart(%{options: options}) when length(options) > 0 do
    data = Enum.map(options, fn option -> [option.text, option.votes] end)
    dataset = Dataset.new(data, ["Option", "Votes"])

    chart =
      dataset
      |> BarChart.new([
        padding: 25,
        custom_value_formatter: &integer_formatter/1,
        colour_palette: ["14B8A6"],
        series_fill_colours: %Contex.CategoryColourScale{
          colour_map: %{1 => "1f77b4"},
          colour_palette: ["14B8A6"],
          default_colour: nil,
          values: [1]
        },
      ])

    Plot.new(500, 300, chart)
    |> Plot.to_svg()
    |> Phoenix.HTML.raw()
  end

  def generate_chart(_), do: nil

  defp integer_formatter(val) when val == round(val), do: Integer.to_string(round(val))
  defp integer_formatter(_val), do: ""
end
