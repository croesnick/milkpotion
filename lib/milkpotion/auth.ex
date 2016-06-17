defmodule Milkpotion.Auth do
  alias Milkpotion.Base.Url
  alias Milkpotion.Request

  def auth_token(frob) do
    frob |> Url.auth_token_url |> Request.get
  end
end
