@testset "Grids" begin

	include("grid_tests/CreateGrids.jl")
	include("grid_tests/ExportImport.jl")
	include("grid_tests/DensityApproximation.jl")
	include("grid_tests/Subdivide.jl")
	include("grid_tests/Refine.jl")
	include("grid_tests/Integration.jl")
	include("grid_tests/PDFandCDF.jl")
	include("grid_tests/Slice.jl")

end