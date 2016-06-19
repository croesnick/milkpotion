defmodule Milkpotion.Base.RateLimiter do
  @rpi Application.get_env(:milkpotion, :max_requests_per_interval)
  @interval Application.get_env(:milkpotion, :rate_limit_interval)
  @max_tries Application.get_env(:milkpotion, :max_retries_if_over_rate)
  @bucket Application.get_env(:milkpotion, :api_key)

  def run(method, url, body \\ "", headers \\ %{}, tries \\ 0)

  @spec run(atom, binary, binary, map, non_neg_integer) :: {:error, :rtm, binary}
  def run(_method, url, _body, _headers, tries) when tries >= @max_tries, do: error(url)

  @spec run(atom, binary, binary, map, non_neg_integer) :: {:ok, map} | {:error, :rtm, binary}
  def run(method, url, body, headers, tries) do
    case ExRated.check_rate(@bucket, @interval, @rpi) do
      {:ok, _} ->
        perform_call(method, url, body, headers, tries)
      {:error, _} ->
        retry(method, url, body, headers, tries)
    end
  end

  @spec perform_call(atom, binary, binary, map, non_neg_integer) :: {:ok, map} | {:error, :rtm, binary}
  defp perform_call(:get, url, body, headers, tries) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 503}} ->
        retry(:get, url, body, headers, tries)
      response ->
        response
    end
  end

  @spec perform_call(atom, binary, binary, map, non_neg_integer) :: {:ok, map} | {:error, :rtm, binary}
  defp perform_call(:post, url, body, headers, tries) do
    headers =
      %{'Content-Type' => 'application/json'}
      |> Map.merge(headers)
      |> Enum.into([])

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 503}} ->
        retry(:post, url, body, headers, tries)
      response ->
        response
    end
  end

  @spec retry(atom, binary, binary, map, non_neg_integer) :: {:ok, map} | {:error, :rtm, binary}
  defp retry(method, url, body, headers, tries) do
    :timer.sleep(@interval)
    run(method, url, body, headers, tries + 1)
  end

  @spec error(binary) :: {:error, :rtm, binary}
  defp error(url) do
    {:error, :rtm, "Could not call #{url}: Constantly over rate limit."}
  end
end
