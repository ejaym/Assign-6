defmodule P2 do
  def q2 do
    n = 1
    do_loop(n)
  end

  defp do_loop(n) when n != 0 do
    IO.write("Enter a number: ")
    input = IO.gets("") |> String.trim()

    case Integer.parse(input) do
      {0, ""} ->
        process_number(0)

      {num, ""} ->
        process_number(num)
        do_loop(num)

      _ ->
        IO.puts("Not an integer.")
        do_loop(n)
    end
  end

  defp do_loop(0), do: :ok

  defp process_number(num) when is_integer(num) do
    cond do
      num < 0 ->
        result = abs(:math.pow(num, 7))
        IO.puts(result)

      num == 0 ->
        IO.puts(num)
        do_loop_end()

      rem(num, 7) == 0 ->
        result = :math.pow(num, 1 / 5)
        IO.puts(result)

      true ->
        result = factorial(num)
        IO.puts(result)
    end
  end

  defp process_number(_) do
    IO.puts("Not an integer.")
  end

  defp do_loop_end do
    IO.puts("Exiting the loop.")
  end

  defp factorial(0), do: 1

  defp factorial(n) when n > 0 do
    n * factorial(n - 1)
  end
end
