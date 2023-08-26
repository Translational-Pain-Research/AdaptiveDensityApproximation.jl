# Assumes that tests from ( CreateGrids.jl , ExportImport.jl , DomainRestriction.jl) have passed.


@testset "Sum 1-dim" begin
	grid = named_1d_grid()

	# Test that warnings are printed if an empty grid is returned.
	@test_warn "Boundaries" sum(grid, lower = -10, upper = -4)
	@test_warn "Boundaries" sum(x-> x^2,grid, lower = -10, upper = -4)

	# Test default value for too restrictive bounds.
	@test sum(grid, lower = -10, upper = -4) == 0
	@test sum(x->2*x,grid, lower = -10, upper = -4) == 0

	# Basic sums.
	@test sum(grid) == sum(export_weights(grid))
	@test sum(x-> 2*x,grid) == 2*sum(export_weights(grid))

	# Restricted domain sums (sufficient to test only weight_distribution = :linear to check argument passing).
	# Without function.
	@test sum(grid, lower = 2) == 2
	@test sum(grid, lower = 1.5, weight_distribution = :linear) == 0.5 + 2
	# With function.
	@test sum(x-> 2*x, grid, lower = 2) == 4
	@test sum(x-> 2*x, grid, lower = 1.5, weight_distribution = :linear) == 2*(0.5 + 2)
	
	# Mutation test.
	centers, volumes, weights = export_all(grid)
	@test centers == [1.5,2.5]

end



@testset "Sum 2-dim" begin
	grid = named_2d_grid()

	# Test that warnings are printed if an empty grid is returned.
	@test_warn "Boundaries" sum(grid, lower = [-10,-10], upper = [-4,-4])
	@test_warn "Boundaries" sum(x->2*x,grid, lower = [-10,-10], upper = [-4,-4])

	# Test default value for too restrictive bounds.
	@test sum(grid, lower = [-10,-10], upper = [-4,-4]) == 0
	@test sum(x-> 2*x,grid, lower = [-10,-10], upper = [-4,-4]) == 0

	# Basic sums.
	@test sum(grid) == sum(export_weights(grid))
	@test sum(x-> 2*x,grid) == 2*sum(export_weights(grid))

	# Restricted domain sums (sufficient to test only weight_distribution = :linear to check argument passing).
	# Without function.
	@test sum(grid, lower = [2,2]) == 2
	@test sum(grid, lower = [1.5,2], weight_distribution = :linear) == 0.5 + 2
	# With function.
	@test sum(x-> 2*x, grid, lower = [2,2]) == 4
	@test sum(x-> 2*x, grid, lower = [1.5,2], weight_distribution = :linear) == 2*(0.5 + 2)
	
	# Mutation test.
	centers, volumes, weights = export_all(grid)
	@test centers == [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]]

end






@testset "Product 1-dim" begin
	grid = named_1d_grid()


	# Test that warnings are printed if an empty grid is returned.
	@test_warn "Boundaries" prod(grid, lower = -10, upper = -4)
	@test_warn "Boundaries" prod(x-> x^2,grid, lower = -10, upper = -4)

	# Test default value for too restrictive bounds.
	@test prod(grid, lower = -10, upper = -4) == 1
	@test prod(x-> 2*x,grid, lower = -10, upper = -4) == 1

	# Basic sums.
	@test prod(grid) == prod(export_weights(grid))
	@test prod(x-> 2*x,grid) == 2^2*prod(export_weights(grid))

	# Restricted domain sums (sufficient to test only weight_distribution = :linear to check argument passing).
	# Without function.
	@test prod(grid, lower = 2) == 2
	@test prod(grid, lower = 1.5, weight_distribution = :linear) ==  0.5 * 2
	# With function.
	@test prod(x-> 2*x, grid, lower = 2) == 4
	@test prod(x-> 2*x, grid, lower = 1.5, weight_distribution = :linear) == 2^2*(0.5 * 2)
	
	# Mutation test.
	centers, volumes, weights = export_all(grid)
	@test centers == [1.5,2.5]

end



@testset "Product 2-dim" begin
	grid = named_2d_grid()

	# Test that warnings are printed if an empty grid is returned.
	@test_warn "Boundaries" prod(grid, lower = [-10,-10], upper = [-4,-4])
	@test_warn "Boundaries" prod(x->2*x,grid, lower = [-10,-10], upper = [-4,-4])

	# Test default value for too restrictive bounds.
	@test prod(grid, lower = [-10,-10], upper = [-4,-4]) == 1
	@test prod(x->2*x,grid, lower = [-10,-10], upper = [-4,-4]) == 1

	# Basic sums.
	@test prod(grid) == prod(export_weights(grid))
	@test prod(x-> 2*x,grid) == 2^4*prod(export_weights(grid))

	# Restricted domain sums (sufficient to test only weight_distribution = :linear to check argument passing).
	# Without function.
	@test prod(grid, lower = [2,2]) == 2
	@test prod(grid, lower = [1.5,2], weight_distribution = :linear) == 0.5 * 2
	# With function.
	@test prod(x-> 2*x, grid, lower = [2,2]) == 4
	@test prod(x-> 2*x, grid, lower = [1.5,2], weight_distribution = :linear) == 2^2 *(0.5 * 2)
	
	# Mutation test.
	centers, volumes, weights = export_all(grid)
	@test centers == [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]]

end