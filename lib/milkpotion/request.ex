defmodule Milkpotion.Request do
  require Logger
  alias Milkpotion.Base.RateLimiter

  @spec get(binary, map) :: {:ok, map} | {:error, atom, binary | map}
  def get(url, headers \\ %{}) do
    with {_, response}  <- RateLimiter.run(:get, url, "", headers),
         {:ok, body}    <- parse_http_response(response),
         {:ok, _} = rtm <- parse_rtm_response(body), do: rtm
  end

  @spec parse_http_response(%HTTPoison.Response{}) :: {:ok, binary}
  def parse_http_response(%HTTPoison.Response{status_code: 200, body: body}) do
    {:ok, body}
  end

  @spec parse_http_response(%HTTPoison.Response{}) :: {:error, :http, binary}
  def parse_http_response(%HTTPoison.Response{status_code: code}) do
    error_message = "Unexpected: RTM service responded with #{code}."
    _ = Logger.error error_message

    {:error, :http, error_message}
  end

  @spec parse_http_response(%HTTPoison.Error{}) :: {:error, :http, binary}
  def parse_http_response(%HTTPoison.Error{reason: reason}) do
    _ = Logger.info "Could not fetch data. Reason: #{reason}"
    {:error, :http, reason}
  end

  @spec parse_rtm_response(binary) :: {:ok, map} | {:error, atom, binary} | {:error, atom, map}
  def parse_rtm_response(raw) do
    ret = with {:ok, data} <- Poison.decode(raw),
               {:ok, body} <- extract_rtm_body(data),
               :ok         <- extract_rtm_status(body) do
                 {:ok, body}
          end

    case ret do
      {:ok, _} = success        -> success
      {:error, :invalid}        -> {:error, :json, "Parse error: bad format"}
      {:error, {:invalid, msg}} -> {:error, :json, "Parse error: #{msg}"}
      {:error, _, _} = failure  -> failure
    end
  end

  @spec extract_rtm_body(map) :: {:ok, map} | {:error, :json, binary}
  defp extract_rtm_body(data) when is_map(data) do
    case Map.fetch(data, "rsp") do
      {:ok, _} = success ->
        success
      :error ->
        {:error, :json, "Bad response: it did not contain the field \"rsp\"."}
    end
  end

  @spec extract_rtm_status(map) :: :ok | {:error, atom, binary | map}
  defp extract_rtm_status(data) when is_map(data) do
    case Map.fetch(data, "stat") do
      {:ok, status} ->
        case status do
          "ok" ->
            :ok
          "fail" ->
            case extract_rtm_error(data) do
              {:ok, info} ->
                {:error, :request, info}
              {:error, _, _} = error ->
                error
            end
        end
      :error ->
        {:error, :json, "Bad response: it did not contain the field \"stat\"."}
    end
  end

  @spec extract_rtm_error(map) :: {:ok, map} | {:error, :json, binary}
  defp extract_rtm_error(data) when is_map(data) do
    ret = with {:ok, error}   <- Map.fetch(data, "err"),
               {:ok, code}    <- Map.fetch(error, "code"),
               {:ok, message} <- Map.fetch(error, "msg") do
                 {:ok, %{code: code, message: message}}
          end

    case ret do
      {:ok, _} = success ->
        success
      :error ->
        error_message = "Could not parse error information from response: #{inspect data}"

        _ = Logger.error error_message
        {:error, :json, error_message}
    end
  end
end
