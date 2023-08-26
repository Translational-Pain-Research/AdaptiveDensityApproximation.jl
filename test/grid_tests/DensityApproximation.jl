# Assumes that tests from ( CreateGrids , ExportImport.jl ) have passed.


@testset "Density approximation: 1-dim" begin
	grid = named_1d_grid()


	@testset "No volume normalization" begin
		# Choose non-trivial function, s.t. different approximation modes lead to different weights.
		f = x -> x^2
		
		approximate_density!(grid,f) # default mode = :center
		@test export_weights(grid) ==  [1.5^2,2.5^2]

		approximate_density!(grid,f, mode= :mean)
		@test export_weights(grid) ==  [0.5*(1+2^2), 0.5*(2^2+3^2)]

		approximate_density!(grid,f, mode= :mesh, mesh_size = 3)
		@test export_weights(grid) ==  [(1+1.5^2+2^2)/3, (2^2+2.5^2+3^2)/3]


		# Check that grid is still well defined.
		target_centers = [1.5,2.5]
		target_volumes = [1,1]
		target_weights = [(1+1.5^2+2^2)/3, (2^2+2.5^2+3^2)/3]

		standard_gird_tests(grid,target_centers,target_volumes,target_weights)

		# Test proper return value.
		returned_grid = approximate_density!(grid,f)
		@test returned_grid == grid
	end



	@testset "Volume correction" begin

		# Use simple function to isolate volume normalization effect.
		# x->x leads to identical raw weights for all modes (modes tested above). |  ∑_i (center +Δx_i)/n = center
		f = x->x
		# Define grid that has different volumes.
		grid = create_grid([1,3,4])
		target_weights = [4,3.5]

		# Different modes are only tested to check that volume_normalization is applied for all modes.
		approximate_density!(grid,f,volume_normalization = true)
		@test export_weights(grid) == target_weights
		approximate_density!(grid,f,volume_normalization = true, mode = :mean)
		@test export_weights(grid) == target_weights
		approximate_density!(grid,f,volume_normalization = true, mode = :mesh)
		@test export_weights(grid) == target_weights
	end

end


@testset "Density approximation: 2-dim" begin
	grid = named_2d_grid()


	@testset "No volume normalization" begin

		# Non-trivial function would be better, but defining the target weights becomes cumbersome.
		# X -> X[1] + X[2] leads to same target weights for all approximation modes.
		f= X -> X[1] + X[2]
		target_weights = [3.0,4.0,4.0,5.0]

		approximate_density!(grid,f)
		@test export_weights(grid) ==  target_weights

		approximate_density!(grid,f, mode = :mean)
		@test export_weights(grid) ==  target_weights

		approximate_density!(grid,f, mode = :mesh, mesh_size = 5)
		@test export_weights(grid) ==  target_weights


		# Check that grid is still well defined.
		target_centers = [[1.5,1.5],[1.5,2.5],[2.5,1.5],[2.5,2.5]]
		target_volumes = [1,1,1,1]
		standard_gird_tests(grid,target_centers,target_volumes,target_weights)

		# Test proper return value.
		returned_grid = approximate_density!(grid,f)
		@test returned_grid == grid

	end


	@testset "Volume correction" begin

		# Use simple function to isolate volume normalization effect.
		# X -> X[1] + X[2] leads to same raw weights for all approximation modes.
		f = X -> X[1] + X[2]

		# Define grid that has different volumes.
		grid = create_grid([1,3,4], [1,2,5])
		target_weights = [2*(2+1.5),6*(2+3.5), 3.5+1.5, 3*(3.5+3.5)] # volume * (X[1] + X[2])

		# Different modes are only tested to check that volume_normalization is applied for all modes.
		approximate_density!(grid,f,volume_normalization = true)
		@test export_weights(grid) == target_weights
		approximate_density!(grid,f,volume_normalization = true, mode = :mean)
		@test export_weights(grid) == target_weights
		approximate_density!(grid,f,volume_normalization = true, mode = :mesh)
		@test export_weights(grid) == target_weights
	end
end
