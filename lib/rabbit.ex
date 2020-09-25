defmodule AmqpReader.Rabbit do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    state = %{
      connection: nil,
      channel: nil,
      uri: Keyword.fetch!(opts, :uri),
      ack: Keyword.fetch!(opts, :ack),
      queue: Keyword.fetch!(opts, :queue)
    }

    {:ok, state, {:continue, :connect}}
  end

  def handle_continue(:connect, state) do
    with {:ok, connection} <- AMQP.Connection.open(state.uri),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      {:noreply, %{state | connection: connection, channel: channel}}
    else
      error -> {:stop, error, state}
    end
  end

  def handle_call(:get, _from, state) do
    message = AMQP.Basic.get(state.channel, state.queue, no_ack: !!state.ack)

    {:reply, message, state}
  end
end
