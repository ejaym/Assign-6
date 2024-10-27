defmodule Server do
  def start do
    serv3 = spawn(__MODULE__, :serv3, [])
    Process.register(serv3, :serv3)

    serv2 = spawn(__MODULE__, :serv2, [serv3])
    Process.register(serv2, :serv2)

    serv1 = spawn(__MODULE__, :serv1, [serv2])
    Process.register(serv1, :serv1)

    IO.puts("Servers started")
    main_loop(serv1)
  end

  def main_loop(serv1) do
    :timer.sleep(1000)
    IO.puts("Enter your Arguments:")

    case IO.read(:line) do
      :eof ->
        IO.puts("End of file. Exiting.")
        :ok

      {:error, reason} ->
        IO.puts("Error reading input: #{inspect(reason)}")
        main_loop(serv1)

      data ->
        term = String.trim(data) |> Code.string_to_quoted!()

        if term == :all_done do
          send(serv1, :halt)
          IO.puts("Exiting main loop.")
          :ok
        else
          send(serv1, term)
          main_loop(serv1)
        end
    end
  end

  def serv1(serv2) do
    receive do
      :halt ->
        send(serv2, :halt)
        IO.puts("(serv1) Stopping.")

      :update ->
        IO.puts("(serv1) Updating to new code.")
        case Code.load_file(__ENV__.file) do
          [{module, _}] when module == __MODULE__ ->
            IO.puts("(serv1) Code updated successfully.")
            __MODULE__.serv1(serv2)

          {:error, reason} ->
            IO.puts("(serv1) Code update failed: #{inspect(reason)}")
            serv1(serv2)
        end

      {op, x, y} when op == :add and is_number(x) and is_number(y) ->
        result = x + y
        IO.puts("(serv1) add(#{x}, #{y}) = #{result}")
        serv1(serv2)

      {op, x, y} when op == :sub and is_number(x) and is_number(y) ->
        result = x - y
        IO.puts("(serv1) sub(#{x}, #{y}) = #{result}")
        serv1(serv2)

      {op, x, y} when op == :mult and is_number(x) and is_number(y) ->
        result = x * y
        IO.puts("(serv1) mult(#{x}, #{y}) = #{result}")
        serv1(serv2)

      {op, x, y} when op == :div and is_number(x) and is_number(y) ->
        result = x / y
        IO.puts("(serv1) div(#{x}, #{y}) = #{result}")
        serv1(serv2)

      {op, x} when op == :neg and is_number(x) ->
        result = -x
        IO.puts("(serv1) neg(#{x}) = #{result}")
        serv1(serv2)

      {op, x} when op == :sqrt and is_number(x) ->
        result = :math.sqrt(x)
        IO.puts("(serv1) sqrt(#{x}) = #{result}")
        serv1(serv2)

      msg ->
        send(serv2, msg)
        serv1(serv2)
    end
  end

  def serv2(serv3) do
    receive do
      :halt ->
        send(serv3, :halt)
        IO.puts("(serv2) Exiting.")

      :update ->
        IO.puts("(serv2) Updating to new code.")
        case Code.load_file(__ENV__.file) do
          [{module, _}] when module == __MODULE__ ->
            IO.puts("(serv2) Code updated successfully.")
            __MODULE__.serv2(serv3)

          {:error, reason} ->
            IO.puts("(serv2) Code update failed: #{inspect(reason)}")
            serv2(serv3)
        end

      [head | tail] when is_integer(head) ->
        numbers = Enum.filter([head | tail], &is_number/1)
        sum = Enum.sum(numbers)
        IO.puts("(serv2) Sum of numbers: #{sum}")
        serv2(serv3)

      [head | tail] when is_float(head) ->
        numbers = Enum.filter([head | tail], &is_number/1)
        product = Enum.reduce(numbers, 1, &*/2)
        IO.puts("(serv2) Product of numbers: #{product}")
        serv2(serv3)

      msg ->
        send(serv3, msg)
        serv2(serv3)
    end
  end

  def serv3 do
    serv3(0)
  end

  def serv3(count) do
    receive do
      :halt ->
        IO.puts("(serv3) Exiting. Unprocessed messages: #{count}")

      :update ->
        IO.puts("(serv3) Updating to new code.")
        case Code.load_file(__ENV__.file) do
          [{module, _}] when module == __MODULE__ ->
            IO.puts("(serv3) Code updated successfully.")
            __MODULE__.serv3(count)

          {:error, reason} ->
            IO.puts("(serv3) Code update failed: #{inspect(reason)}")
            serv3(count)
        end

      {:error, msg} ->
        IO.puts("(serv3) Error: #{inspect(msg)}")
        serv3(count)

      msg ->
        IO.puts("(serv3) Not handled: #{inspect(msg)}")
        serv3(count + 1)
    end
  end
end
