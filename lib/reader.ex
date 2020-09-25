defmodule AmqpReader do
  @moduledoc """
  Documentation for `AmqpReader`.
  """

  use GenServer
  require Logger

  @default_poll :timer.seconds(1)

  def init(opts) do
    state = %{
      count: 0,
      uri: Keyword.get(opts, :uri),
      queue: Keyword.get(opts, :queue),
      dir: Keyword.get(opts, :dir, "."),
      max: Keyword.get(opts, :max),
      ack: Keyword.get(opts, :ack),
      tail: Keyword.get(opts, :tail),
      poll: Keyword.get(opts, :poll, @default_poll),
      polling: false
    }

    {:ok, state, {:continue, :start}}
  end

  def start(opts) do
    GenServer.start(__MODULE__, opts, name: :amqp_reader)
  end

  def handle_continue(:start, state) do
    {:ok, _} = AmqpReader.Rabbit.start_link(uri: state.uri, queue: state.queue, ack: state.ack)

    schedule_next(0)
    {:noreply, state}
  end

  def schedule_next(time) do
    :timer.send_after(time, :get)
  end

  def handle_info(:get, state) do
    state =
      case GenServer.call(AmqpReader.Rabbit, :get) do
        {:empty, _map} ->
          if state.tail do
            if !state.polling, do: Logger.info("polling every #{state.poll} milliseconds")
            schedule_next(state.poll)
          else
            {:stop, "all #{state.count} messages consumed", state}
          end

          %{state | polling: true}

        {:ok, message, _meta} ->
          file =
            state.count
            |> Integer.to_string()
            |> String.pad_leading(5, ["0"])

          File.write(Path.join([state.dir, "msg-#{file}"]), message)

          schedule_next(0)
          %{state | polling: false, count: state.count + 1}
      end

    if state.max && state.max <= state.count do
      {:stop, "max messages (#{state.max}) consumed", state}
    else
      {:noreply, state}
    end
  end
end
