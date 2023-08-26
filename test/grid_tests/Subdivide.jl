@testset "Subdivide: 1-dim" begin
	grid = named_1d_grid()
	returned_grid = subdivide!(grid,"b_left")
	# Test proper return value.
	@test returned_grid == grid

	# Block "left" should be replaced by two smaller blocks.
	@test !("b_left" in collect(keys(grid)))
	@test length(grid) == 3
	
	# Test properties of the subdivided grid.
	target_centers = [1.25,1.75,2.5]
	target_volumes = [0.5,0.5,1]
	target_weights = [1,1,2]
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)

	# Test weight_splitting.
	grid = named_1d_grid()
	returned_grid = subdivide!(grid,"b_left"; split_weights = true)

	# Test properties of the subdivided grid.
	target_weights = [0.5,0.5,2]
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)
end


@testset "Subdivide: 2-dim" begin
	grid = named_2d_grid()
	returned_grid = subdivide!(grid,"b_top_left")
	# Test proper return value.
	@test returned_grid == grid

	# Block "top_left" should be replaced by two smaller blocks.
	@test !("b_top_left" in collect(keys(grid)))
	@test length(grid) == 7
	
	# Test properties of the subdivided grid.
	target_centers = [[1.25,2.25],[1.25,2.75],[1.5,1.5],[1.75,2.25],[1.75,2.75],[2.5,1.5],[2.5,2.5]]
	target_volumes = [0.25,0.25,1,0.25,0.25,1,1]
	target_weights = [1,1,3,1,1,4,2]
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)


	# Test weight_splitting.
	grid = named_2d_grid()
	returned_grid = subdivide!(grid,"b_top_left"; split_weights = true)

	# Test properties of the subdivided grid.
	target_weights = [0.25,0.25,3,0.25,0.25,4,2]
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)
end
