module AdaptiveDensityApproximation

# Generate random strings.
using Random

# Extend these methods for defined types.
import Base.length
import Base.getindex
import Base.values
import Base.keys

include("Blocks.jl")
include("Grid.jl")

end
