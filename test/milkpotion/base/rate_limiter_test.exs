defmodule Milkpotion.Base.RateLimiterTest do
  use ExUnit.Case, async: true
  alias Milkpotion.Base.RateLimiter

  test "when the tries as exceeded for the api key" do
    uri = "http://api.example.com"
    max_tries = Application.get_env(:milkpotion, :rtm_rate_limit_max_tries)

    assert {:error, :rtm, _} = RateLimiter.run(uri, max_tries)
  end

  test "when the call succeeds" do
    uri = "http://api.example.com"

    :meck.expect(:hackney, :request, fn(:get, ^uri, _, _, _) -> {:ok, 200, ""} end)
    assert {:ok, %HTTPoison.Response{status_code: 200}} = RateLimiter.run(uri)
  end

  test "when only the first few calls are over rate limit" do
    uri = "http://api.example.com"
    max_tries = Application.get_env(:milkpotion, :rtm_rate_limit_max_tries)

    {:ok, store} = Agent.start_link fn -> 0 end

    fun = fn(:get, ^uri, _, _, _) ->
      if Agent.get(store, fn state -> state end) < max_tries - 1 do
        :ok = Agent.update(store, fn state -> state + 1 end)
        {:ok, 503, ""}
      else
        {:ok, 200, ""}
      end
    end

    :meck.expect(:hackney, :request, fun)
    assert {:ok, %HTTPoison.Response{status_code: 200}} = RateLimiter.run(uri)

    Agent.stop(store)
  end

  test "when the client is constantly over rate limit" do
    uri = "http://api.example.com"

    :meck.expect(:hackney, :request, fn(:get, ^uri, _, _, _) -> {:ok, 503, ""} end)
    assert {:error, :rtm, _} = RateLimiter.run(uri)
  end
end
