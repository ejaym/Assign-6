defmodule P1 do
  def q1 do
    IO.write("Enter a number: ")
    input = IO.gets("") |> String.trim()

    case Integer.parse(input) do
      {num, ""} -> process_number(num)
      _ -> IO.puts("Not an integer.")
    end
  end

  defp process_number(num) when is_integer(num) do
    cond do
      num < 0 ->
        result = abs(:math.pow(num, 7))
        IO.puts(result)

      num == 0 ->
        IO.puts(num)

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

  defp factorial(0), do: 1

  defp factorial(n) when n > 0 do
    n * factorial(n - 1)
  end
end
