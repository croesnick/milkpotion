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

  test "when the client is constantly over rate limit" do
    uri = "http://api.example.com"

    :meck.expect(:hackney, :request, fn(:get, ^uri, _, _, _) -> {:ok, 503, ""} end)
    assert {:error, :rtm, _} = RateLimiter.run(uri)
  end
end
