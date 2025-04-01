defmodule TodoApi.RebalanceWorker do
  @moduledoc """
  Worker for rebalancing positions of a user's tasks when the gap gets too small
  """

  use GenServer
  alias TodoApi.Tasks

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(state), do: {:ok, state}

  def rebalance(user_id), do: GenServer.cast(__MODULE__, {:rebalance, user_id})

  def handle_cast({:rebalance, user_id}, state) do
    Tasks.rebalance_positions(user_id)
    {:noreply, state}
  end
end
