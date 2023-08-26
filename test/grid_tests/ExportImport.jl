@testset "Export and import: 1-dim" begin
	grid = named_1d_grid()
	target_centers = [1.5,2.5]
	target_volumes = [1,1]
	target_weights = [1,2]

	@test export_weights(grid) == target_weights

	returned_grid = import_weights!(grid, [2.0,3.0])
	# Test that weights are imported correctly.
	@test export_weights(grid) == [2.0,3.0]
	# Test proper return value.
	@test returned_grid == grid

	centers, volumes, weights = export_all(grid)
	@test centers == target_centers
	@test volumes  == target_volumes
	# Not target_weights because of import! tests.
	@test weights == [2,3]

	# Check that the grid is still well defined.
	# Use weights instead of target_weights because of the import! tests.
	standard_gird_tests(grid,target_centers,target_volumes,weights)
end




@testset "Export and import: 2-dim" begin
	grid = named_2d_grid()
	target_centers = [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]]
	target_volumes = [1,1,1,1]
	target_weights = [3,1,4,2]

	@test export_weights(grid) == target_weights

	returned_grid = import_weights!(grid,[1.0,2.0,3.0,4.0])
	# Test that weights are imported correctly.
	@test export_weights(grid) == [1.0,2.0,3.0,4.0]
	# Test proper return value.
	@test returned_grid == grid

	centers, volumes, weights = export_all(grid)
	@test centers ==  target_centers
	@test volumes == target_volumes
	# Not target_weights because of import! tests.
	@test weights == [1.0,2.0,3.0,4.0]

	# Check that the grid is still well defined.
	# Use weights instead of target_weights because of the import! tests.
	standard_gird_tests(grid,target_centers,target_volumes,weights)
end
