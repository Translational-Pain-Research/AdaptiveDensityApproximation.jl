@testset "Get slice" begin

	grid = named_2d_grid()

	# Slice in x-axis -> [bottom_left, bottom_right].
	standard_gird_tests(get_slice(grid, [nothing,1.5]), [1.5,2.5],[1,1], [3,4])

	# Slice in y-axis -> [bottom_left, top_left].
	standard_gird_tests(get_slice(grid, [1.5,nothing]), [1.5,2.5],[1,1], [3,1])


	# Slice from 3 dimensions to 2 dimensions.
	grid = create_grid([1,2,3],[1,2,3],[1,2,3])
	standard_gird_tests(get_slice(grid, [1.5,nothing, nothing]), [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]],ones(4), ones(4))
	standard_gird_tests(get_slice(grid, [nothing, 1.5, nothing]), [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]],ones(4), ones(4))
	standard_gird_tests(get_slice(grid, [nothing,nothing, 1.5]), [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]],ones(4), ones(4))

	# Slice from 3 dimensions to 1 dimension.
	standard_gird_tests(get_slice(grid, [1.5,1.5, nothing]), [1.5,2.5],[1,1],[1,1])
	standard_gird_tests(get_slice(grid, [1.5,nothing,1.5]), [1.5,2.5],[1,1],[1,1])
	standard_gird_tests(get_slice(grid, [nothing,1.5,1.5]), [1.5,2.5],[1,1], [1,1])

end