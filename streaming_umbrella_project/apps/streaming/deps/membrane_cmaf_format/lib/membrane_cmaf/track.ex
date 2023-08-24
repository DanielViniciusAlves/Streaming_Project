defmodule Membrane.CMAF.Track do
  @moduledoc """
  Membrane description for a single track in Common Media Application Format.
  """

  @enforce_keys [
    :content_type,
    :header
  ]
  defstruct @enforce_keys

  @type content_type_t() :: :audio | :video

  @typedoc """
  Struct describing a single track in Common Media Application Format.

  The header field should contain binary contents of a CMAF init file.
  """
  @type t :: %__MODULE__{
          content_type: content_type_t() | [content_type_t()],
          header: binary
        }
end
