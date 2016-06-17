defmodule Milkpotion.Base.RateLimiterTest do
  use ExUnit.Case, async: false
  alias Milkpotion.Base.RateLimiter

  @max_tries Application.get_env(:milkpotion, :max_retries_if_over_rate)
  @bucket Application.get_env(:milkpotion, :api_key)

  setup do
    bypass = Bypass.open
    uri = "http://localhost:#{bypass.port}"

    # Delete the rate limiter bucket after every test
    on_exit fn -> ExRated.delete_bucket(@bucket) end

    {:ok, bypass: bypass, uri: uri}
  end

  test "when the tries as exceeded for the api key", %{uri: uri} do
    assert {:error, :rtm, _} = RateLimiter.run(uri, @max_tries)
  end

  test "when the call succeeds", %{bypass: bypass, uri: uri} do
    Bypass.expect bypass, fn conn ->
      assert "/" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, ~s<{}>)
    end
    assert {:ok, %HTTPoison.Response{status_code: 200}} = RateLimiter.run(uri)
  end

  test "when only the first few calls cause the service to respond with a 503", %{bypass: bypass, uri: uri} do
    {:ok, store} = Agent.start_link fn -> 0 end

    Bypass.expect bypass, fn conn ->
      assert "/" == conn.request_path
      assert "GET" == conn.method

      if Agent.get(store, fn state -> state end) < @max_tries - 1 do
        :ok = Agent.update(store, fn state -> state + 1 end)
        Plug.Conn.resp(conn, 503, ~s<{}>)
      else
        Plug.Conn.resp(conn, 200, ~s<{}>)
      end
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = RateLimiter.run(uri)

    Agent.stop(store)
  end

  test "when only the first few calls are over rate limit", %{bypass: bypass, uri: uri} do
    rpi = Application.get_env(:milkpotion, :max_requests_per_interval)
    interval = Application.get_env(:milkpotion, :rate_limit_interval)

    Bypass.expect bypass, fn conn ->
      assert "/" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, ~s<{}>)
    end

    {:ok, _} = ExRated.check_rate(@bucket, interval, rpi)
    assert {:ok, %HTTPoison.Response{status_code: 200}} = RateLimiter.run(uri)
  end

  test "when the client is constantly over rate limit", %{bypass: bypass, uri: uri} do
    Bypass.expect bypass, fn conn ->
      assert "/" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 503, ~s<{}>)
    end
    assert {:error, :rtm, _} = RateLimiter.run(uri)
  end
end
