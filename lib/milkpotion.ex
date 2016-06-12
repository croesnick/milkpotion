defmodule Milkpotion do
  @doc """
  Returns the application's api_key as configured in the
  environment's config file.
  """
  def api_key do
    Application.get_env(:milkpotion, :api_key)
  end

  @doc """
  Returns the application's shared_secret as configured in the
  environment's config file.
  """
  def shared_secret do
    Application.get_env(:milkpotion, :shared_secret)
  end
end
