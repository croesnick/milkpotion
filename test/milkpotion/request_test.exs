defmodule Milkpotion.RequestTest do
  use ExUnit.Case
  alias Milkpotion.Request

  doctest Milkpotion.Request

  test "#parse_http_response with 200er response" do
    response = %HTTPoison.Response{status_code: 200, body: "[]"}
    assert {:ok, "[]"} == Request.parse_http_response(response)
  end

  test "#parse_http_response with non-200er response" do
    response = %HTTPoison.Response{status_code: 400, body: "[]"}
    assert {:error, :http, _} = Request.parse_http_response(response)
  end

  test "#parse_http_response with failed request" do
    response = %HTTPoison.Error{reason: "bad request"}
    assert {:error, :http, "bad request"} == Request.parse_http_response(response)
  end

  test "#parse_rtm_response with valid data" do
    body = %{"stat" => "ok", "field" => "value"}
    json = Poison.encode! %{"rsp" => body}
    assert {:ok, body} == Request.parse_rtm_response(json)
  end

  test "#parse_rtm_response with missing 'rsp' field" do
    json = Poison.encode! %{"resp" => "does not matter"}
    assert {:error, :json, _} = Request.parse_rtm_response(json)
  end

  test "#parse_rtm_response with missing 'stat' field" do
    json = Poison.encode! %{"rsp" => %{"field" => "value"}}
    assert {:error, :json, _} = Request.parse_rtm_response(json)
  end

  test "#parse_rtm_response with stat = fail" do
    error = %{"code" => 123, "msg" => "forbidden"}
    json  = Poison.encode! %{"rsp" => %{"stat" => "fail", "err" => error}}
    assert {:error, :request, %{code: 123, message: "forbidden"}} == Request.parse_rtm_response(json)
  end
end
