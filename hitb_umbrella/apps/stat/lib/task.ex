defmodule Stat.Task do
  use GenServer
  alias Stat.StatCdaService
  alias Hitb.Time

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: Task)
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    time = Time.stime_local()|>String.split(" ")|>List.last
    if(String.contains?(time, " 03:00"))do
      IO.puts "====自动执行病案搜索索引更新任务,当前时间#{Time.stime_local()}===="
      StatCdaService.comp()
      IO.puts "====更新完成,明日03:00:00执行下次更新===="
      Process.send_after(self(), :work, 24 * 60 * 60 * 1000) # In 24 hours
    else
      IO.puts "====明日03:00:00执行病案搜索索引更新任务===="
      date = "#{Time.sdate_tom} 03:00:00"
      Process.send_after(self(), :work, Time.time_difference(date, Time.stime_local()) * 1000)
    end
  end

end
