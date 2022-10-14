@testset "1-dim pdf" begin
	grid = create_grid(collect(LinRange(-5,5,11)))
	p(x) = 1/sqrt(2*pi) * exp(-x^2/2)
	approximate_density!(grid,p)

	# Normalized pdf.
	f = get_pdf(grid)
	@test typeof(f) <: Function

	# Test values outside the grid range.
	@test f(-6) == 0
	@test f(6) == 0


	# Test values inside the grid range.
	centers, volumes, weights = export_all(grid)
	for i in eachindex(centers)
		@test f(centers[i]) ≈ weights[i]/sum(weights)
	end

	# Unnormalized pdf.
	g = get_pdf(grid, normalize = false)
	@test typeof(g) <: Function

	# Test values outside the grid range.
	@test g(-6) == 0
	@test g(6) == 0


	# Test values inside the grid range.
	centers, volumes, weights = export_all(grid)
	for i in eachindex(centers)
		@test g(centers[i]) ≈ weights[i]
	end
end













@testset "1-dim cdf" begin
	grid = create_grid(collect(LinRange(-5,5,11)))
	p(x) = 1/sqrt(2*pi) * exp(-x^2/2)
	approximate_density!(grid,p)

	# Normalized pdf.
	f = get_cdf(grid)
	@test typeof(f) <: Function

	# Test values outside the grid range.
	@test f(-6) == 0
	@test f(6) ≈ 1


	# Test values inside the grid range.
	centers, volumes, weights = export_all(grid)
	for i in eachindex(centers)
		@test f(centers[i]) ≈ sum(weights[1:i-1])/sum(weights)
	end

	# Unnormalized pdf.
	g = get_cdf(grid, normalize = false)
	@test typeof(g) <: Function

	# Test values outside the grid range.
	@test g(-6) == 0
	@test g(6) ≈ sum(weights)


	# Test values inside the grid range.
	centers, volumes, weights = export_all(grid)
	for i in eachindex(centers)
		@test g(centers[i]) ≈ sum(weights[1:i-1])
	end
end














@testset "2-dim pdf" begin
	grid = create_grid(collect(LinRange(-5,5,11)), collect(LinRange(-5,5,11)))
	p(x) = 1/sqrt(2*pi) * exp(-x[1]^2/2 - x[2]/2)
	approximate_density!(grid,p)

	# Normalized pdf.
	f = get_pdf(grid)
	@test typeof(f) <: Function

	# Test values outside the grid range.
	@test f([-6,-6]) == 0
	@test f([6,6]) == 0


	# Test values inside the grid range.
	centers, volumes, weights = export_all(grid)
	for i in eachindex(centers)
		@test f(centers[i]) ≈ weights[i]/sum(weights)
	end

	# Unnormalized pdf.
	g = get_pdf(grid, normalize = false)
	@test typeof(g) <: Function

	# Test values outside the grid range.
	@test g([-6,-6]) == 0
	@test g([6,6]) == 0


	# Test values inside the grid range.
	centers, volumes, weights = export_all(grid)
	for i in eachindex(centers)
		@test g(centers[i]) ≈ weights[i]
	end
end













@testset "2-dim cdf" begin
	grid = create_grid([-1,0,1],[-1,0,1])
	p(x) = 1/sqrt(2*pi) * exp(-x[1]^2/2 - x[2]/2)
	approximate_density!(grid,p)

	centers, volumes, weights = export_all(grid)

	# Normalized pdf.
	f = get_cdf(grid)
	@test typeof(f) <: Function

	# Test values outside the grid range.
	@test f([-2,-2]) == 0
	@test f([2,2]) ≈ 1
	
	# Test values inside the grid range.
	@test f([-0.5,-0.5]) == 0
	@test f([0.5,-0.5]) == 0
	@test f([-0.5,0.5]) == 0
	@test f([0.5,0.5]) ≈ p([-0.5,-0.5])/sum(weights)
	@test f([2,0.5]) ≈ (p([-0.5,-0.5]) + p([0.5,-0.5]))/sum(weights)
	@test f([0.5,2]) ≈ (p([-0.5,-0.5]) + p([-0.5,0.5]))/sum(weights)

	# Unnormalized pdf.
	g = get_cdf(grid, normalize = false)
	@test typeof(g) <: Function

	# Test values outside the grid range.
	@test g([-2,-2]) == 0
	@test g([2,2]) ≈ sum(weights)

	# Test values inside the grid range.
	@test g([-0.5,-0.5]) == 0
	@test g([0.5,-0.5]) == 0
	@test g([-0.5,0.5]) == 0
	@test g([0.5,0.5]) ≈ p([-0.5,-0.5])
	@test g([2,0.5]) ≈ (p([-0.5,-0.5]) + p([0.5,-0.5]))
	@test g([0.5,2]) ≈ (p([-0.5,-0.5]) + p([-0.5,0.5]))

end
