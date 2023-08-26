# Assumes that tests from ( CreateGrids.jl , ExportImport.jl ) have passed.

@testset "Select Indices 1-dim grid" begin
	grid = create_grid([10,20,30,40,50,60])
	
	@test select_indices(grid) == collect(1:5)
	@test select_indices(grid,lower=40) == collect(4:5)
	@test select_indices(grid,upper=40) == collect(1:3)
	@test select_indices(grid,lower = 20,upper=40) == collect(2:3)
end

@testset "Select Indices 2-dim grid" begin
	grid = create_grid([10,20,30,40],[100,200,300,400])
	
	centers,volumes,weights = export_all(grid)
	# Core function to obtain indices for comparison (stripped from boundary checks and efficient loop design).
	indices(lower,upper) = findall(x-> prod(lower[i]<= x[i] <= upper[i] for i in eachindex(x)), centers)
	
	# Dimension of bounds must match the grid dimension (2-dimensional).
	@test_throws DimensionMismatch select_indices(grid,lower = [1,2,3])
	@test_throws DimensionMismatch select_indices(grid,upper = [1,2,3])
	@test_throws DimensionMismatch select_indices(grid,lower = [1,2,3],upper = [1,2,3])

	@test select_indices(grid) == collect(1:9)
	@test select_indices(grid,lower = [30,300]) == indices([30,300],[Inf,Inf])
	@test select_indices(grid,upper = [30,300]) == indices([-Inf,-Inf],[30,300])
	@test select_indices(grid,lower = [20,200],upper = [30,300]) == indices([20,200],[30,300])
end