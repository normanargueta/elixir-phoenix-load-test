defmodule Mix.Tasks.LoadTest do
  use Mix.Task

  alias ElixirPhoenixLoadTest.Repo
  alias ElixirPhoenixLoadTest.Accounts.User

  @shortdoc "Seed data, run load test, cleanup"
  @tag "load_test_"

  def run(args) do
    Mix.Task.run("app.start")

    count = parse_count(args)

    IO.puts("→ Seeding #{count} users...")
    {time, _} = :timer.tc(fn -> seed_data(count) end)
    IO.puts("  Done in #{Float.round(time / 1_000_000, 2)}s")

    IO.puts("→ Running k6 via Docker...")
    {_, exit_code} = run_load_test()

    IO.puts("→ Cleaning up...")
    cleanup()

    if exit_code != 0 do
      Mix.raise("k6 exited with code #{exit_code}")
    end

    IO.puts("✓ All done!")
  end

  defp seed_data(count) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    1..count
    |> Stream.map(fn i ->
      %{
        email: "#{@tag}#{i}@test.com",
        name: "Load Test User #{i}",
        inserted_at: now,
        updated_at: now
      }
    end)
    |> Stream.chunk_every(1_000)
    |> Enum.each(&Repo.insert_all(User, &1))
  end

  defp cleanup do
    import Ecto.Query

    {count, _} = Repo.delete_all(
      from u in User, where: like(u.email, ^"#{@tag}%")
    )

    IO.puts("  Deleted #{count} records")
  end

  defp run_load_test do
    {host, extra_args} =
      case :os.type() do
        {:unix, :darwin} -> {"host.docker.internal", []}
        _ -> {"localhost", ["--network", "host"]}
      end

    base_url = "http://#{host}:4000"
    IO.puts("  Target: #{base_url}")

    System.cmd("docker", [
      "run", "--rm",
      "-v", "#{File.cwd!()}:/scripts",
      "-e", "BASE_URL=#{base_url}"
    ] ++ extra_args ++ [
      "grafana/k6", "run", "/scripts/priv/k6/load_test.js"
    ], into: IO.stream(:stdio, :line), stderr_to_stdout: true)
  end

  defp parse_count([count_str | _]) do
    case Integer.parse(count_str) do
      {count, _} -> count
      :error -> Mix.raise("Invalid count: #{count_str}")
    end
  end

  defp parse_count([]), do: 10_000
end
