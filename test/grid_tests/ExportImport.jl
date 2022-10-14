@testset "Export and import: 1-dim" begin
	grid = named_1d_grid()
	target_centers = Set([1.5,2.5])
	target_volumes = Set([1])

	# Order of blocks for export is [left, right].
	@test export_weights(grid) == [1.0,2.0]

	returned_grid = import_weights!(grid, [2.0,3.0])
	@test export_weights(grid) == [2.0,3.0]
	# Test proper return value.
	@test returned_grid == grid

	centers, volumes, weights = export_all(grid)
	@test Set(centers) == target_centers
	@test Set(volumes)  == target_volumes
	@test weights == [2.0,3.0]

	# Check that the grid is still well defined.
	standard_gird_tests(grid,target_centers,target_volumes,Set(weights))
end




@testset "Export and import: 2-dim" begin
	grid = named_2d_grid()
	target_centers = Set([[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]])
	target_volumes = Set([1])

	# Order of blocks for export/import is [bottom_left,top_left,bottom_right,top_right].
	@test export_weights(grid) == [3.0,1.0,4.0,2.0]

	returned_grid = import_weights!(grid,[1.0,2.0,3.0,4.0])
	@test export_weights(grid) == [1.0,2.0,3.0,4.0]
	# Test proper return value.
	@test returned_grid == grid

	centers, volumes, weights = export_all(grid)
	@test Set(centers) ==  target_centers
	@test Set(volumes) == target_volumes
	@test weights == [1.0,2.0,3.0,4.0]

	# Check that the grid is still well defined.
	standard_gird_tests(grid,target_centers,target_volumes,Set(weights))
end
