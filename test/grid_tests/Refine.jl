@testset "Refine: 1-dim" begin

	# Test refine! in detail.
	grid = named_1d_grid()
	custom_variation = (center,volume,weight,centers,volumes,weights) -> maximum(weights) - weight
	returned_grid, change_indices = refine!(grid, block_variation = custom_variation, selection = minimum)

	@test !("a_right" in collect(keys(grid)))
	@test length(grid) == 3


	# Test return values.
	@test returned_grid == grid
	@test change_indices == [2,3]
	
	# Test properties of the subdivided grid.
	target_centers = Set([1.5,2.25,2.75])
	target_volumes = Set([0.5,1])
	target_weights = Set([1,2])
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)





	# Test default block variation (should replace both blocks in this case).
	grid = named_1d_grid()
	refine!(grid)
	@test !("b_left" in collect(keys(grid))) && !("a_right" in collect(keys(grid)) )
	@test length(grid) == 4


	# Test volume selection (should replace both blocks in this case).
	custom_variation =(center,volume,weight,centers,volumes,weights) -> volume + maximum(volume)
	grid = named_1d_grid()
	refine!(grid, block_variation = custom_variation)
	@test !("b_left" in collect(keys(grid))) && !("a_right" in collect(keys(grid)) )
	@test length(grid) == 4

	# Test center selection (should replace left in this case).
	custom_variation = (center,volume,weight,centers,volumes,weights) -> maximum(centers) - center
	grid = named_1d_grid()
	refine!(grid, block_variation = custom_variation)
	@test !("b_left" in collect(keys(grid)))
	@test length(grid) == 3
end



@testset "Refine: 2-dim" begin

	# Test refine! in detail.
	grid = named_2d_grid()
	custom_variation(center,volume,weight,centers,volumes,weights) = weight
	returned_grid, change_indices = refine!(grid, block_variation = custom_variation)

	# Block "bottom_right" should be replaced by two smaller blocks.
	@test !("x_bottom_right" in collect(keys(grid)))
	@test length(grid) == 7

	# Test return values.
	@test returned_grid == grid
	# Test change_indices based on block weights, which remain unchanged by refine/subdivide.
	@test export_weights(grid)[change_indices] == [4,4,4,4]

	
	# Test properties of the subdivided grid.
	target_centers = Set([[1.5,1.5],[2.5,2.5],[1.5,2.5],[2.25,1.25],[2.25,1.75],[2.75,1.25],[2.75,1.75]])
	target_volumes = Set([0.25,1])
	target_weights = Set([1,2,3,4])
	standard_gird_tests(grid,target_centers,target_volumes,target_weights)

	# Test default block variation (should replace all blocks in this case).
	grid = named_2d_grid()
	refine!(grid)
	@test !("b_top_left" in collect(keys(grid))) && !("a_top_right" in collect(keys(grid))) && !("y_bottom_left" in collect(keys(grid))) && !("x_bottom_right" in collect(keys(grid)))
	@test length(grid) == 16
end