using AdaptiveDensityApproximation
import AdaptiveDensityApproximation as ADA
using Test






# Test function f against target for both argument orders.
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

# Create 1-dim grid with known names.
# Names are chosen such that their alphabetic order and the order of the centers of the corresponding blocks do not match. 
function named_1d_grid()
	return ADA.OneDimGrid(Dict("b_left" => ADA.OneDimBlock("b_left",ADA.Interval(1,2),["a_right"],1.0), 
		"a_right" => ADA.OneDimBlock("a_right", ADA.Interval(2,3), ["b_left"], 2.0) ))
end



# | b_top_left [1,2] [2,3] 1.0    | a_top_right [2,3] [2,3] 2.0    |
# |-------------------------------|--------------------------------|
# | y_bottom_left [1,2] [1,2] 3.0 | x_bottom_right [2,3] [1,2] 4.0 |

# Create 2-dim grid with known names.
# Names are chosen such that their alphabetic order and the order of the centers of the corresponding blocks do not match. 
function named_2d_grid()
	top_left = ADA.Block("b_top_left", ADA.Cuboid([ADA.Interval(1,2), ADA.Interval(2,3)]), ["a_top_right", "y_bottom_left"],1.0)
	top_right = ADA.Block("a_top_right", ADA.Cuboid([ADA.Interval(2,3), ADA.Interval(2,3)]), ["b_top_left", "x_bottom_right"],2.0)
	bottom_left = ADA.Block("y_bottom_left", ADA.Cuboid([ADA.Interval(1,2), ADA.Interval(1,2)]), ["b_top_left", "x_bottom_right"],3.0)
	bottom_right = ADA.Block("x_bottom_right", ADA.Cuboid([ADA.Interval(2,3), ADA.Interval(1,2)]), ["a_top_right", "y_bottom_left"],4.0)
	return ADA.Grid(Dict(zip(["b_top_left", "a_top_right", "y_bottom_left", "x_bottom_right"],[top_left,top_right,bottom_left,bottom_right])))
end




# Functions to test if grid is well defined
####################################################################################################


# Create list of expected neighbors by testing all other blocks in the grid.
# Check neighboring function needs to be tested before using this function.
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

# Brute-force check that all neighbors in a grid are correct.
function brute_force_neighbor_check(grid)
	for block in values(grid)
		if Set(block.neighbors) != Set(expected_neighbors(grid,block))
			return false
		end
	end
	return true
end


# Test that grid is well defined.
function standard_gird_tests(grid, target_centers::T1, target_volumes::T2, target_weights::T3) where {T1 <: Set, T2 <: Set, T3 <: Set}
	dict_keys = collect(keys(grid))
	blocks = [grid[key] for key in dict_keys]

	# Dict keys and block names must match.
	@test  dict_keys == [block.name for block in blocks]

	# Check if neighbor lists are correct.
	@test brute_force_neighbor_check(grid)

	# Check if centers and volumes are correct.
	@test  Set([ADA.center(block) for block in blocks]) == target_centers
	@test  Set([ADA.volume(block) for block in blocks]) == target_volumes
	
	# Check if the blocks have the proper weight.
	@test Set([block.weight for block in blocks]) == target_weights
end