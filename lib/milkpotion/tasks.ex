defmodule Milkpotion.Tasks do
  alias Milkpotion.Base.Url
  alias Milkpotion.Request

  @spec get_list(binary) :: {:ok, map} | {:error, atom, binary | map}
  def get_list(token) do
    Url.rest("rtm.tasks.getList", token) |> Request.get
  end
end
