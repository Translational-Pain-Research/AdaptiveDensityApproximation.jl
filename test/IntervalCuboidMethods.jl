@testset "Operations on Intervals" begin
	# Shortcut to define Intervals.
	I = ADA.Interval

	@testset "Correct order" begin
		@test I(2,1).left == 1
		@test I(1,2).left == 1
	end

	@testset "Center" begin
		@test ADA.center(I(1,2)) == 1.5
	end

	@testset "Corners" begin
		@test ADA.corners(I(1,2)) == [1,2]
	end

	@testset "Volume" begin
		@test ADA.volume(I(1,2)) == 1
	end

	@testset "Intermediate points" begin
		@test ADA.intermediate_points(I(1,2),3) == [1,1.5,2]
	end

	@testset "Check overlapping" begin
		test = ADA.intervals_overlapping

		@test symmetric_test(true,test,I(1,2),I(0,3))# Interval contained.
		@test symmetric_test(true,test,I(1,2),I(1.5,3))# Overlapping.

		@test symmetric_test(false,test,I(1,2),I(2,3))# Neighboring.
		@test symmetric_test(false,test,I(1,2),I(3,4))# Disjunct.
	end

	@testset "Check neighboring" begin
		test = ADA.check_neighboring

		@test symmetric_test(false,test,I(1,2),I(0,3))# Interval contained.
		@test symmetric_test(false,test,I(1,2),I(1.5,3))# Overlapping.
		@test symmetric_test(false,test,I(1,2),I(3,4))# Disjunct.

		@test symmetric_test(true,test,I(1,2),I(2,3))# Neighboring.
	end
end







@testset "Operations on Cuboids" begin
	# Shortcut to define Cuboids from arrays
	C(args...) = ADA.Cuboid([ADA.Interval(arg...) for arg in args])

	@testset "Center" begin
		@test ADA.center(C([1,2],[1,2])) == [1.5,1.5]
	end

	@testset "Corners" begin
		@test Set(ADA.corners(C([1,2],[1,2]))) ==  Set([[i,j] for i in 1:2 for j in 1:2])
	end

	@testset "Volume" begin
		@test ADA.volume(C([1,2],[1,2])) == 1
	end

	@testset "Intermediate points" begin
		@test Set(ADA.intermediate_points(C([1,2],[1,2]),3)) ==  Set([[i,j] for i in [1,1.5,2] for j in [1,1.5,2]])
	end

	@testset "Check overlapping hyper-surfaces" begin
		# Test if cuboid c1 and c2 overlap in dimension i.
		test_1(c1,c2) = ADA.hypersurfaces_overlapping(c1,c2,2)
		test_2(c1,c2) = ADA.hypersurfaces_overlapping(c1,c2,1)

		# Hyper-surfaces contained.
		@test symmetric_test(true,test_1,C([1,2],[1,2]), C([1.2,1.8],[3,4])) 
		@test symmetric_test(true,test_2,C([1,2],[1,2]), C([3,4], [1.2,1.8])) 

		# Hyper-surfaces overlapping.
		@test symmetric_test(true,test_1,C([1,2],[1,2]), C([1.5,3],[3,4]))
		@test symmetric_test(true,test_2,C([1,2],[1,2]), C([3,4], [1.5,3]))

		# Hyper-surfaces neighboring.
		@test symmetric_test(false,test_1,C([1,2],[1,2]), C([2,3],[3,4]))
		@test symmetric_test(false,test_2,C([1,2],[1,2]), C([3,4],[2,3]))

		# Hyper-surfaces disjunct.
		@test symmetric_test(false,test_1,C([1,2],[1,2]), C([2,3],[3,4]))
		@test symmetric_test(false,test_2,C([1,2],[1,2]), C([3,4],[2,3]))
	end

	@testset "Check neighboring" begin
		test = ADA.check_neighboring
		
		@test symmetric_test(true,test , C([1,2],[1,2]), C([0,3],[2,3])) # Contained in dim 1.
		@test symmetric_test(true,test , C([1,2],[1,2]), C([2,3],[0,3])) # dim 2.

		@test symmetric_test(true,test , C([1,2],[1,2]), C([1.5,3],[2,3])) # Overlapping in dim 1.
		@test symmetric_test(true,test , C([1,2],[1,2]), C([2,3],[1.5,3])) # dim 2.


		@test symmetric_test(false,test , C([1,2],[1,2]), C([3,4],[1,2])) # Disjoint in dim 1.
		@test symmetric_test(false,test , C([1,2],[1,2]), C([1,2],[3,4])) # dim 2.

		@test symmetric_test(false,test , C([1,2],[1,2]), C([2,3],[2,3])) # Only corners.
		@test symmetric_test(false,test , C([1,2],[1,2]), C([3,4],[3,4])) # Completely disjoint.

	end

end