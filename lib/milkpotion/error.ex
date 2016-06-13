defmodule Milkpotion.Error do
  @type t :: %__MODULE__{code: integer, message: String.t}
  defstruct code: nil, message: nil
end
