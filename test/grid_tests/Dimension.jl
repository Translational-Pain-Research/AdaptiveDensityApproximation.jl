@testset "Dimension tests" begin
	@test dimension(create_grid([1,2,3])) == 1
	@test dimension(create_grid([1,2,3],[1,2,3])) == 2
	@test dimension(create_grid([1,2,3],[1,2,3],[1,2,3])) == 3
end