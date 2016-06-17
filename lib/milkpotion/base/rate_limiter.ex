defmodule Milkpotion.Base.RateLimiter do
  @rpi Application.get_env(:milkpotion, :max_requests_per_interval)
  @interval Application.get_env(:milkpotion, :rate_limit_interval)
  @max_tries Application.get_env(:milkpotion, :max_retries_if_over_rate)
  @bucket Application.get_env(:milkpotion, :api_key)

  def run(url, tries) when tries >= @max_tries, do: error(url)
  def run(url, tries \\ 0) do
    case ExRated.check_rate(@bucket, @interval, @rpi) do
      {:ok, _} ->
        case HTTPoison.get(url) do
          {:ok, %HTTPoison.Response{status_code: 503}} ->
            retry(url, tries)
          response ->
            response
        end
      {:error, _} ->
        retry(url, tries)
    end
  end

  defp retry(url, tries) do
    :timer.sleep(@interval)
    run(url, tries + 1)
  end

  defp error(url) do
    {:error, :rtm, "Could not call #{url}: Constantly over rate limit."}
  end
end
