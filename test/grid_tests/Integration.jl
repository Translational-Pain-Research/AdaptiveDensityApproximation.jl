# Assumes that tests from ( ExportImport.jl ) have passed.


@testset "Integrate: 1-dim" begin
	grid = named_1d_grid()

	# integrate: ∑_i volume_i * weight_i = 1*1 + 1*2.
	@test integrate(grid) == 3
	# integrate should not change block weights.
	@test export_weights(grid) == [1,2]
end


@testset "Integrate: 2-dim" begin
	grid = named_2d_grid()

	# integrate: ∑_i volume_i * weight_i = 1*1 + 1*2+ ... + 1*4.
	@test integrate(grid) == 10
	# integrate should not change block weights.
	@test export_weights(grid) == [3,1,4,2]
end


@testset "Integral model: 1-dim" begin
	grid = named_1d_grid()
	# Order of blocks is [left, right] -> weights = [1,2].

	model, weights, ∂ = integral_model(grid,(x,center,weight)->x*center*weight, (x,center,weight) -> x * center)
	# Should return: 
	# model(x,λ) = ∑_i volume_i * weight_i * center_i * x = 6.5 x for λ = weights.
	# ∂(x,λ) = [volume_1 * center_1 * x, volume_2 * center_2 * x] = [1*1.5*x, 1*2.5*x].
	# weights = [1,2] (order of blocks [left,right]).



	@test weights == [1,2]

	# Approximately equal to correct for floating point errors.
	@test prod([model(x,weights) ≈ 6.5*x for x in LinRange(-10,10,100)]) == 1
	@test prod([∂[1](x,weights) ≈ 1.5*x for x in LinRange(-10,10,100)]) == 1
	@test prod([∂[2](x,weights) ≈ 2.5*x for x in LinRange(-10,10,100)]) == 1



	# Test variable arguments.
	model, weights, ∂ = integral_model(grid,(x,center,weight,y)-> sum(x) + y *  center*weight)
	# model(x,λ,y) = ∑_i volume_i * (sum(x) + y * weight_i * center_i).
	@test model(zeros(10),weights,1) ≈ 6.5
end



@testset "Integral model: 2-dim" begin
	grid = named_2d_grid()

	model, weights, ∂ = integral_model(grid,(x,center,weight)->x*sum(center) * weight, (x,center,weight) -> x*sum(center))
	# Should return: 
	# model(x,λ) = ∑_i volume_i * weight_i * center_i * x = 39 * x for λ = weights.
	# ∂(x,λ) = [volume_1 * sum(center_1_j) * x, ... , volume_4 * sum(center_4_j) * x] = [3*x, 4*x, 4*x, 5*x].
	# weights = [3,4,1,2] (order of blocks [bottom_left, bottom_right, top_left, top_right]).

	@test weights == [3.0,1.0,4.0,2.0] 

	# Approximately equal to correct for floating point errors.
	@test prod([model(x,weights) ≈ 39*x for x in LinRange(-10,10,100)]) == 1
	@test prod([∂[1](x,weights) ≈ 3*x for x in LinRange(-10,10,100)]) == 1
	@test prod([∂[2](x,weights) ≈ 4*x for x in LinRange(-10,10,100)]) == 1
	@test prod([∂[3](x,weights) ≈ 4*x for x in LinRange(-10,10,100)]) == 1
	@test prod([∂[4](x,weights) ≈ 5*x for x in LinRange(-10,10,100)]) == 1


	# Test variable arguments.
	model, weights, ∂ = integral_model(grid,(x,center,weight,y)-> sum(x) + y *  sum(center) *weight)
	# model(x,λ,y) = ∑_i volume_i * (sum(x) + y * weight_i * center_i).
	@test model(zeros(10),weights,1) ≈ 39
end
