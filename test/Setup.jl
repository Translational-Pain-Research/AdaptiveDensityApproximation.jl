using AdaptiveDensityApproximation
import AdaptiveDensityApproximation as ADA
using Test






# Test function equality of function with target value, irrespective of argument order.
function symmetric_test(target,f,arg_1,arg_2)
	if target == f(arg_1,arg_2) == f(arg_2,arg_1)
		return true
	else
		return false
	end
end






# Create grids with known properties.
####################################################################################################


# | b_left [1,2] 1.0 | a_right [2,3] 2.0 |

# Create 1-dim grid with known names and properties.
# Names are purposefully chosen such that their alphabetic order and the order of the respective centers do not match. 
function named_1d_grid()
	return ADA.OneDimGrid(Dict(
		"b_left" => ADA.OneDimBlock("b_left",ADA.Interval(1,2),["a_right"],1.0), 
		"a_right" => ADA.OneDimBlock("a_right", ADA.Interval(2,3), ["b_left"], 2.0)
		))
end



# | b_top_left [1,2] [2,3] 1.0    | a_top_right [2,3] [2,3] 2.0    |
# |-------------------------------|--------------------------------|
# | y_bottom_left [1,2] [1,2] 3.0 | x_bottom_right [2,3] [1,2] 4.0 |

# Create 1-dim grid with known names and properties.
# Names are purposefully chosen such that their alphabetic order and the order of the respective centers do not match. 
function named_2d_grid()
	top_left = ADA.Block("b_top_left", ADA.Cuboid([ADA.Interval(1,2), ADA.Interval(2,3)]), ["a_top_right", "y_bottom_left"],1.0)
	top_right = ADA.Block("a_top_right", ADA.Cuboid([ADA.Interval(2,3), ADA.Interval(2,3)]), ["b_top_left", "x_bottom_right"],2.0)
	bottom_left = ADA.Block("y_bottom_left", ADA.Cuboid([ADA.Interval(1,2), ADA.Interval(1,2)]), ["b_top_left", "x_bottom_right"],3.0)
	bottom_right = ADA.Block("x_bottom_right", ADA.Cuboid([ADA.Interval(2,3), ADA.Interval(1,2)]), ["a_top_right", "y_bottom_left"],4.0)
	return ADA.Grid(Dict(zip(["b_top_left", "a_top_right", "y_bottom_left", "x_bottom_right"],[top_left,top_right,bottom_left,bottom_right])))
end




# Functions to test if a grid is well defined.
####################################################################################################


# Create list of expected neighbors by testing all other blocks in the grid (brute force approach).
# `check_neighboring` function needs to be tested before using this function.
function expected_neighbors(grid, block_of_interst)
	blocks = [grid[key] for key in keys(grid)]
	neighbors = String[]
	for block in blocks
		if ADA.check_neighboring(block,block_of_interst)
			push!(neighbors,block.name)
		end
	end
	return neighbors
end

# Check that all neighbors in a grid are correct (brute-force approach).
function brute_force_neighbor_check(grid)
	for block in values(grid)
		# The order of neighbors is irrelevant (brute-force approach leads to different order anyway).
		if Set(block.neighbors) != Set(expected_neighbors(grid,block))
			return false
		end
	end
	return true
end


# Check that grid is well defined.
# Enforce sets for the target-parameters, as the order is irrelevant (brute-force tests lead to different order anyway).
function standard_gird_tests(grid, target_centers, target_volumes, target_weights)
	dict_keys = collect(keys(grid))
	blocks = [grid[key] for key in dict_keys]

	# Dict keys and block names must match.
	@test  dict_keys == [block.name for block in blocks]

	# Check if neighbor lists are correct.
	@test brute_force_neighbor_check(grid)

	# Check if centers and volumes are correct.
	perm = sortperm([ADA.center(block) for block in blocks])
	@test  [ADA.center(block) for block in blocks][perm] == target_centers
	@test  [ADA.volume(block) for block in blocks][perm] == target_volumes
	
	# Check if the blocks have the proper weight.
	@test [block.weight for block in blocks][perm] == target_weights
end