defmodule Milkpotion.Auth do
  alias Milkpotion.Base.Url
  alias Milkpotion.Request

  @spec get_token(binary) :: {:ok, map} | {:error, atom, binary | map}
  def get_token(frob) do
    Url.rest("rtm.auth.getToken", nil, %{"frob" => frob}) |> Request.get
  end

  @spec check_token(binary) :: {:ok, map} | {:error, atom, binary | map}
  def check_token(token) do
    Url.rest("rtm.auth.checkToken", token) |> Request.get
  end
end
