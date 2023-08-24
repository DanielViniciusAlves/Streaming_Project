defmodule Membrane.MP4.Payload.AVC1 do
  @moduledoc """
  H264 content description for `Membrane.MP4.Payload`.
  """

  @type t :: %__MODULE__{
          avcc: binary,
          inband_parameters?: boolean()
        }
  @enforce_keys [:avcc, :inband_parameters?]
  defstruct @enforce_keys
end
