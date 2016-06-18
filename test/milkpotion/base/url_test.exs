defmodule Milkpotion.Base.UrlTest do
  use ExUnit.Case
  alias Milkpotion.Base.Url

  def query_dict_from_uri(uri) do
    uri
    |> URI.parse
    |> Map.fetch!(:query)
    |> URI.decode_query
  end

  test "auth/1" do
    uri = Url.auth("test.method")
    assert %{"method"  => "test.method",
             "api_key" => _,
             "api_sig" => _} = query_dict_from_uri(uri)
  end

  test "auth/2" do
    uri = Url.auth("test.method", %{"key" => "value"})
    assert %{"method"  => "test.method",
             "key"     => "value",
             "api_key" => _,
             "api_sig" => _} = query_dict_from_uri(uri)
  end

  test "rest/2" do
    uri = Url.rest("test.method", "sample_token")
    assert %{"method"     => "test.method",
             "auth_token" => "sample_token",
             "api_key"    => _,
             "api_sig"    => _} = query_dict_from_uri(uri)
  end

  test "rest/3" do
    uri = Url.rest("test.method", "sample_token", %{"key" => "value"})
    assert %{"method"     => "test.method",
             "auth_token" => "sample_token",
             "key"        => "value",
             "api_key"    => _,
             "api_sig"    => _} = query_dict_from_uri(uri)
  end

  test "init_auth/1" do
    uri = Url.init_auth("write")
    assert %{"perms"   => "write",
             "api_key" => _,
             "api_sig" => _} = query_dict_from_uri(uri)
  end
end
