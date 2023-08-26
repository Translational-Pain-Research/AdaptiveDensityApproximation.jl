module AdaptiveDensityApproximation

# Generate random strings.
using Random

# Extend these methods for defined types.
import Base.length
import Base.getindex
import Base.values
import Base.keys
import Base.sum
import Base.prod

include("Blocks.jl")

include("GridMethods/TypeDefinitions.jl")
include("GridMethods/CreateGrid.jl")
include("GridMethods/ImportAndExport.jl")
include("GridMethods/AdaptiveRefinement.jl")
include("GridMethods/DensityApproximation.jl")
include("GridMethods/GridRestrictions.jl")
include("GridMethods/Calculations.jl")

end
