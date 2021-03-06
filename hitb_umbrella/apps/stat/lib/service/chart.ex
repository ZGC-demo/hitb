defmodule Stat.Chart do
  alias Stat.Key

  #通用图调用方法,stat数据类型为[%{day_avg: 3.3537, day_index: 1.0, org: "测试医院1", time: "2016年10月"}, %{day_avg: 3.4386, day_index: 2.0, org: "测试医院1", time: "2016年8月"}]
  def chart(stat, chart_type) do
    unless(stat == [] or stat == nil)do
      #数据data
      data = stat
        |>Enum.map(fn x ->
            case Map.get(x, :drg2) do
              nil -> %{name: x.org <> " " <> x.time, value: Map.values(Map.drop(x, [:org, :time]))}
              _ -> %{name: x.org <> " " <> x.time <> " " <> x.drg2, value: Map.values(Map.drop(x, [:org, :time, :drg2]))}
            end
          end)
      #图key
      chart_key = data|>Enum.map(fn x -> x.name end)
      #返回数据
      case chart_type do
        "radar" ->
          #字段设置(自动判断字段数值限制)
          indicator = stat
            |>Enum.reduce(hd(stat), fn x, res ->
                #自动计算
                Map.keys(x) -- [:org, :time, :drg2]
                |>Enum.reduce(%{}, fn key, acc ->
                    val = if(Map.get(x, key) > Map.get(res, key))do Map.get(x, key) else Map.get(res, key) end
                    Map.put(acc, key, val)
                  end)
              end)
          indicator = hd(stat)
            |>Map.drop([:org, :time, :drg2])
            |>Map.keys
            |>Enum.map(fn x -> %{name: Key.cnkey(x), max: Map.get(indicator, x)} end)
            |>Enum.reject(fn x -> x == nil end)
          %{data: data, chart_key: chart_key, indicator: indicator}
        "bar" ->
          keys = Map.keys(hd(stat)) -- [:org, :time, :drg2]
          #横轴数据
          xAxis = %{type: "category", data: (Enum.map(keys, fn x -> Key.cnkey(x) end) -- ["时间", "机构"]) -- ["病种"]}
          #纵轴数据
          series = Enum.map(data, fn x ->
              %{name: x.name, type: "bar", data: x.value}
            end)
          %{series: series, chart_key: chart_key, xAxis: xAxis}
        "pie" ->
          key = Map.keys(stat|>List.first) -- [:org, :time, :drg2]|>Enum.map(fn x -> Key.cnkey(x) end)
          series = Enum.map(data, fn x -> %{x | :value => hd(x.value)} end)
          data = Enum.map(data, fn x -> x.name end)
          %{series: series, data: data, name: hd(key)}
        "scatter" ->
          chart_data = Enum.map(data, fn x -> x.value end)
          key = Map.keys(hd(stat)) -- [:org, :time, :drg2]
           |>Enum.map(fn x -> Key.cnkey(x) end)
          [xkey|[ykey]] = key
          #x轴最小值
          xSeries = chart_data
            |>Enum.reduce(List.first(List.first(chart_data)), fn x, acc ->
                cond do
                  List.first(x) < acc -> List.first(x)
                  true -> acc
                end
            end)
          #y轴最小值
          ySeries = chart_data
            |>Enum.reduce(List.last(List.last(chart_data)), fn x, acc ->
                cond do
                  List.last(x) < acc -> List.last(x)
                  true -> acc
                end
            end)
          %{data: chart_data, xSeries: xSeries, ySeries: ySeries, xkey: xkey, ykey: ykey}
      end
    else
      %{}
    end
  end
end
