@testset "Create 1-dim grid" begin
	grid = create_grid([1,2,3])
	
	target_centers = [1.5,2.5]
	target_volumes = [1,1]
	target_weights = [1,1]

	standard_gird_tests(grid,target_centers,target_volumes,target_weights)
end


@testset "Create 2-dim grid" begin
	grid = create_grid([1,2,3],[1,2,3])
	
	target_centers = [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]]
	target_volumes = [1,1,1,1]
	target_weights = [1,1,1,1]

	standard_gird_tests(grid,target_centers,target_volumes,target_weights)
end