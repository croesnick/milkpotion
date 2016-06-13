defmodule Milkpotion.Tasks do
  alias Milkpotion.Base.Url
  alias Milkpotion.Request

  def all(token) do
    with request_url     <- Url.build("rtm.tasks.getList", token),
         {:ok, _} = data <- Request.get(request_url), do: data
  end
end
