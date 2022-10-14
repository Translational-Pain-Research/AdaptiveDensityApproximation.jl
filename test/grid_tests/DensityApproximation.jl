@testset "Density approximation: 1-dim" begin
	grid = named_1d_grid()

	# f(x) = x means that all approximation methods should be equal.
	f(x) = x
	target_weights = Set([1.5,2.5])
	
	approximate_density!(grid,f)
	@test Set(export_weights(grid)) ==  target_weights

	approximate_density!(grid,f, mode= :mean)
	@test Set(export_weights(grid)) ==  target_weights

	approximate_density!(grid,f, mode= :mesh, mesh_size = 5)
	@test Set(export_weights(grid)) ==  target_weights


	# Check that grid is still well defined.
	target_centers = Set([1.5,2.5])
	target_volumes = Set([1])
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)

	# Test proper return value.
	returned_grid = approximate_density!(grid,f)
	@test returned_grid == grid
end


@testset "Density approximation: 2-dim" begin
	grid = named_2d_grid()

	# f(X) = X[1] + X[2] means that all approximation methods should be equal.
	f(X) = X[1] + X[2]
	target_weights = Set([3.0,4.0,5.0])

	approximate_density!(grid,f)
	@test Set(export_weights(grid)) ==  target_weights

	approximate_density!(grid,f, mode = :mean)
	@test Set(export_weights(grid)) ==  target_weights

	approximate_density!(grid,f, mode = :mesh, mesh_size = 5)
	@test Set(export_weights(grid)) ==  target_weights


	# Check that grid is still well defined.
	target_centers = Set([[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]])
	target_volumes = Set([1])
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)

	# Test proper return value.
	returned_grid = approximate_density!(grid,f)
	@test returned_grid == grid
end
