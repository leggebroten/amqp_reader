defmodule AmqpReader.CLI do
  require Logger

  def main(args \\ []) do
    {args, _} = OptionParser.parse!(args, strict: opt_spec_list())

    {:ok, pid} = AmqpReader.start(args)

    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, _object, reason} ->
        Logger.info("AmqpReader completed: #{inspect(reason)}")
    end
  end

  defp opt_spec_list,
    do: [
      uri: :string,
      queue: :string,
      dir: :string,
      max: :integer,
      ack: :boolean,
      tail: :boolean,
      poll: :integer
    ]
end
