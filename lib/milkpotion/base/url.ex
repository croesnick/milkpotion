defmodule Milkpotion.Base.Url do
  @auth_service Application.get_env(:milkpotion, :auth_endpoint)
  @rest_service Application.get_env(:milkpotion, :rest_endpoint)

  @doc """
  Builds the request url for calling the rest endpoint with the defined
  `method`. Any `params` will be attached to the request as query
  parameters.

  Returns a complete rest call uri.

  ## Examples

      iex> Url.rest "rtm.test.echo", "sample_token", %{"ping" => "pong"}
      "https://api.rememberthemilk.com/services/rest/?method=rtm.test.echo&api_key=<your_key>&auth_token=sample_token&ping=pong&api_sig=<sig>"
  """
  def rest(method, auth_token, params \\ %{}) do
    params
    |> Map.merge( build_required_params(method, auth_token) )
    |> add_sign_param
    |> add_params_to_uri(@rest_service)
  end

  def auth(method, params \\ %{}) do
    params
    |> Map.merge( build_required_params(method, nil) )
    |> add_sign_param
    |> add_params_to_uri(@auth_service)
  end

  def init_auth(permissions) when permissions in ~w(read write delete) do
    %{"api_key" => Milkpotion.api_key, "perms" => permissions}
    |> add_sign_param
    |> add_params_to_uri(@auth_service)
  end

  ### internal api ###

  defp build_required_params(method, nil) do
    %{"format"  => "json",
      "method"  => method,
      "api_key" => Milkpotion.api_key}
  end

  defp build_required_params(method, auth_token) do
    %{"format"     => "json",
      "method"     => method,
      "api_key"    => Milkpotion.api_key,
      "auth_token" => auth_token}
  end

  defp add_sign_param(params) do
    Map.put params, "api_sig", api_sig(params)
  end

  defp api_sig(params) do
    (Milkpotion.shared_secret <> concat_params(params)) |> md5
  end

  defp add_params_to_uri(params, uri) do
    uri <> "?" <> Enum.map_join(params, "&", fn {key, val} -> key <> "=" <> val end)
  end

  defp concat_params(params) do
    params
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.map_join("", fn {key, val} -> key <> val end)
  end

  defp md5(data) do
    :erlang.md5(data) |> Base.encode16(case: :lower)
  end
end
