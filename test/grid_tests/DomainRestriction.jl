# Assumes that tests from ( ExportImport.jl ) have passed.


@testset "Domain Restriction 1-dim grid" begin
	
	# `lower` must be smaller than `upper`.
	@test_throws DomainError restrict_domain!(named_1d_grid(), lower = 2, upper = 1)
	# Warning if empty grid is returned.
	@test_warn " " restrict_domain!(named_1d_grid(), lower = 10)


	# Return-value / mutation test.
	grid = named_1d_grid()
	mutated_grid = restrict_domain!(grid, lower = 1.5)
	@test mutated_grid == grid

	# Test lower bound.

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), lower = 1.5))
	@test centers == [1.75,2.5]
	@test volumes == [0.5,1]
	@test weights == [1,2]

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), lower = 1.5, weight_distribution = :linear))
	@test centers == [1.75,2.5]
	@test volumes == [0.5,1]
	@test weights == [0.5,2]

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), lower = 1.5, weight_distribution = :log))
	@test centers == [1.75,2.5]
	@test volumes == [0.5,1]
	@test weights == [(log(2)-log(1.5))/(log(2)-log(1)),2]


	# Test upper bound.

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), upper = 2.5))
	@test centers == [1.5,2.25]
	@test volumes == [1,0.5]
	@test weights == [1,2]

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), upper = 2.5, weight_distribution = :linear))
	@test centers == [1.5,2.25]
	@test volumes == [1,0.5]
	@test weights == [1,1]

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), upper = 2.5, weight_distribution = :log))
	@test centers == [1.5,2.25]
	@test volumes == [1,0.5]
	@test weights == [1,2*(log(2.5)-log(2))/(log(3)-log(2))]


	# Test removal of blocks.

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), lower = 2.5))
	@test centers == [2.75]
	@test volumes == [0.5]
	@test weights == [2]

	centers, volumes, weights = export_all(restrict_domain!(named_1d_grid(), upper = 1.5))
	@test centers == [1.25]
	@test volumes == [0.5]
	@test weights == [1]
end

@testset "Domain Restriction 2-dim grid" begin

	# `lower` must be smaller than `upper` in all dimensions.
	@test_throws DomainError restrict_domain!(named_2d_grid(), lower = [3,1], upper = [2,2])
	@test_throws DomainError restrict_domain!(named_2d_grid(), lower = [1,3], upper = [2,2])
	@test_throws DimensionMismatch restrict_domain!(named_2d_grid(), lower = [1,1,1], upper = [2,2])

	# Warning if empty grid is returned.
	@test_warn " " restrict_domain!(named_2d_grid(), lower = [10,10])



	# Return value / mutation test
	grid = named_2d_grid()
	mutated_grid = restrict_domain!(grid, lower = [1.5,1.5])
	@test grid == mutated_grid



	l1 = (log(2)-log(1.5))/(log(2)-log(1))
	l2 = (log(2.5)-log(2))/(log(3)-log(2))

	# Test lower bound.

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), lower = [1.5,1.5]))
	@test centers == [[1.75,1.75],[1.75,2.5],[2.5,1.75],[2.5,2.5]]
	@test volumes == [0.25,0.5,0.5,1]
	@test weights == [3,1,4,2] # named_2d_grid designed with this order of weights (w.r.t. export_weights and export_all).

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), lower = [1.5,1.5], weight_distribution = :linear))
	@test centers == [[1.75,1.75],[1.75,2.5],[2.5,1.75],[2.5,2.5]]
	@test volumes == [0.25,0.5,0.5,1]
	@test weights == [3*0.25,1*0.5,4*0.5,2]

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), lower = [1.5,1.5], weight_distribution = :log))
	@test centers == [[1.75,1.75],[1.75,2.5],[2.5,1.75],[2.5,2.5]]
	@test volumes == [0.25,0.5,0.5,1]
	@test weights == [3*l1*l1,1*l1,4*l1,2]

	# Test upper bound.

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), upper = [2.5,2.5]))
	@test centers == [[1.5,1.5],[1.5,2.25],[2.25,1.5],[2.25,2.25]]
	@test volumes == [1,0.5,0.5,0.25]
	@test weights == [3,1,4,2] # named_2d_grid designed with this order of weights (w.r.t. export_weights and export_all).

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), upper = [2.5,2.5], weight_distribution = :linear))
	@test centers == [[1.5,1.5],[1.5,2.25],[2.25,1.5],[2.25,2.25]]
	@test volumes == [1,0.5,0.5,0.25]
	@test weights == [3,1*0.5,4*0.5,2*0.25]

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), upper = [2.5,2.5], weight_distribution = :log))
	@test centers == [[1.5,1.5],[1.5,2.25],[2.25,1.5],[2.25,2.25]]
	@test volumes == [1,0.5,0.5,0.25]
	@test weights == [3,1*l2,4*l2,2*l2*l2]



	# Test removal of blocks.

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), lower = [2.5,2.5]))
	@test centers == [[2.75,2.75]]
	@test volumes == [0.25]
	@test weights == [2]

	centers, volumes, weights = export_all(restrict_domain!(named_2d_grid(), upper = [1.5,1.5]))
	@test centers == [[1.25,1.25]]
	@test volumes == [0.25]
	@test weights == [3]
end