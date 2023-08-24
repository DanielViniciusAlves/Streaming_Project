defmodule Membrane.MP4.Payload.AAC do
  @moduledoc """
  Advanced Audio Codec content description for `Membrane.MP4.Payload`.
  """
  @type t :: %__MODULE__{
          esds: binary,
          sample_rate: pos_integer,
          channels: pos_integer
        }
  @enforce_keys [:esds, :sample_rate, :channels]
  defstruct @enforce_keys
end
