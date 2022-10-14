@testset "Subdivide: 1-dim" begin
	grid = named_1d_grid()
	returned_grid = subdivide!(grid,"b_left")
	# Test proper return value.
	@test returned_grid == grid

	# Block "left" should be replaced by two smaller blocks.
	@test !("b_left" in collect(keys(grid)))
	@test length(grid) == 3
	
	# Test properties of the subdivided grid.
	target_centers = Set([1.25,1.75,2.5])
	target_volumes = Set([0.5,1])
	target_weights = Set([1,2])
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
	target_centers = Set([[1.5,1.5],[2.5,1.5],[2.5,2.5],[1.25,2.25],[1.25,2.75],[1.75,2.25],[1.75,2.75]])
	target_volumes = Set([0.25,1])
	target_weights = Set([1,2,3,4])
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)
end
