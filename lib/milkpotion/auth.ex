defmodule Milkpotion.Auth do
  alias Milkpotion.Base.Url
  alias Milkpotion.Request

  def get_token(frob) do
    Url.rest("rtm.auth.getToken", nil, %{"frob" => frob}) |> Request.get
  end

  def check_token(token) do
    Url.rest("rtm.auth.checkToken", token) |> Request.get
  end
end
