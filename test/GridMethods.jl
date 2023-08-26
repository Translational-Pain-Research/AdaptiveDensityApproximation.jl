@testset "Grids" begin

	# Order of tests, s.t. assumptions are valid (some tests assume other functions to be already tested).

	include("grid_tests/CreateGrids.jl")
	include("grid_tests/Dimension.jl")
	include("grid_tests/ExportImport.jl")
	include("grid_tests/DensityApproximation.jl") 
	include("grid_tests/Subdivide.jl")
	include("grid_tests/Refine.jl")
	include("grid_tests/Integration.jl")
	include("grid_tests/PDFandCDF.jl")
	include("grid_tests/Slice.jl")
	include("grid_tests/SelectIndices.jl")
	include("grid_tests/DomainRestriction.jl")
	include("grid_tests/SumProduct.jl")
end