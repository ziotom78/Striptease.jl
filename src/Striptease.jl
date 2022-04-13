module Striptease

import SQLite
import HDF5
using AstroTime

# Standard method to convert a TTEpoch to a 64-bit floating point number
tofloat(x::TTEpoch) = modified_julian(x) |> value

include("conventions.jl")
include("datastorage.jl")
include("files.jl")

end
