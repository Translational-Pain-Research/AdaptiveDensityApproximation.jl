include("Setup.jl")

@testset "AdaptiveDensityApproximation.jl" begin
    include("IntervalCuboidMethods.jl")
    include("BlockMethods.jl")
    include("GridMethods.jl")
end
