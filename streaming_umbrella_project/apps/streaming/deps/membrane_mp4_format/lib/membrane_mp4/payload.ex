defmodule Membrane.MP4.Payload do
  @moduledoc """
  MP4 payload description.

  Only a payloaded stream can be muxed into MP4 container.
  """

  @typedoc """
  MP4 payload description.

  Contains the following fields:
  - content - a struct with content-specific information
  - timescale - used to express sample durations within MP4. Each sample duration
    should be a multiply of the timescale for good timing accuracy. Expressed in ticks per second.
  - height - frame height in pixels, should be set to 0 for non-visual streams
  - width - frame width in pixels, should be set to 0 for non-visual streams
  """
  @type t :: %__MODULE__{
          content: struct,
          timescale: pos_integer,
          height: non_neg_integer,
          width: non_neg_integer
        }
  @enforce_keys [:content, :timescale]
  defstruct @enforce_keys ++ [height: 0, width: 0]
end
