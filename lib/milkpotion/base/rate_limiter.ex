defmodule Milkpotion.Base.RateLimiter do
  @rps Application.get_env(:milkpotion, :rtm_rate_limit_rps)
  @max_tries Application.get_env(:milkpotion, :rtm_rate_limit_max_tries)
  @bucket Application.get_env(:milkpotion, :api_key)

  def run(url, tries) when tries >= @max_tries, do: error(url)
  def run(url, tries \\ 0) do
    case ExRated.check_rate(@bucket, 1_000, @rps) do
      {:ok, _} ->
        case HTTPoison.get(url) do
          {:ok, %HTTPoison.Response{status_code: 503}} ->
            error(url)
          response ->
            response
        end
      {:error, _} ->
        :timer.sleep(1_000)
        run(url, tries + 1)
    end
  end

  defp error(url) do
    {:error, :rtm, "Could not call #{url}: Constantly over rate limit."}
  end
end
