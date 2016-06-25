defmodule Milkpotion.Base.Url do
  @moduledoc """
  This module contains url builder functions. These are mainly thought for
  internal use.
  """

  @auth_service Application.get_env(:milkpotion, :auth_endpoint)
  @rest_service Application.get_env(:milkpotion, :rest_endpoint)

  @doc """
  Builds the request url for calling RTM's /rest endopoint with the given
  `method`. Any `params` will be attached to the request as query
  parameters.

  Returns a complete rest call uri.

  ## Examples

      iex> Milkpotiom.Base.Url.rest "rtm.test.echo", "sample_token", %{"ping" => "pong"}
      "https://api.rememberthemilk.com/services/rest/?method=rtm.test.echo&api_key=<your_key>&auth_token=sample_token&ping=pong&api_sig=<sig>"
  """
  @spec rest(binary, nil | binary, map) :: binary
  def rest(method, auth_token, params \\ %{}) do
    params
    |> Map.merge( build_required_params(method, auth_token) )
    |> add_sign_param
    |> add_params_to_uri(@rest_service)
  end

  @doc """
  Builds an auth using your api key with the given `permisions`.

  Returns a complete rest call uri.

  ## Examples

      iex> Milkpotion.Url.init_auth "read"
      "https://www.rememberthemilk.com/services/auth/?api_key=<your_key>&api_sig=<sig>&perms=read"
  """
  @spec init_auth(binary) :: binary
  def init_auth(permissions) when permissions in ~w(read write delete) do
    %{"api_key" => Milkpotion.api_key, "perms" => permissions}
    |> add_sign_param
    |> add_params_to_uri(@auth_service)
  end

  ### internal api ###

  @spec build_required_params(binary, nil) :: map
  defp build_required_params(method, nil) do
    %{"format"  => "json",
      "method"  => method,
      "api_key" => Milkpotion.api_key}
  end

  @spec build_required_params(binary, binary) :: map
  defp build_required_params(method, auth_token) do
    %{"format"     => "json",
      "method"     => method,
      "api_key"    => Milkpotion.api_key,
      "auth_token" => auth_token}
  end

  @spec add_sign_param(map) :: map
  defp add_sign_param(params) do
    Map.put params, "api_sig", api_sig(params)
  end

  @spec api_sig(map) :: binary
  defp api_sig(params) do
    (Milkpotion.shared_secret <> concat_params(params)) |> md5
  end

  @spec add_params_to_uri(map, binary) :: binary
  defp add_params_to_uri(params, uri) do
    uri <> "?" <> Enum.map_join(params, "&", fn {key, val} -> key <> "=" <> val end)
  end

  @spec concat_params(map) :: binary
  defp concat_params(params) do
    params
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.map_join("", fn {key, val} -> key <> val end)
  end

  @spec md5(binary) :: binary
  defp md5(data) do
    :erlang.md5(data) |> Base.encode16(case: :lower)
  end
end
