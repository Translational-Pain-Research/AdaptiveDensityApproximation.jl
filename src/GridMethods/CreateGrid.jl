####################################################################################################
# Creation of grids
####################################################################################################


export create_grid




# Internal functions
####################################################################################################



# Create a unique random string (w.r.t. `excluded_strings`) with length `string_length`.
function unique_random_string(excluded_strings,string_length)
    candidate = randstring(string_length)
    while candidate in excluded_strings
        candidate = randstring(string_length)
    end
    return candidate
end

# Create `n_string` unique random strings of length `string_length`, excluding the `excluded_stings`.
function unique_random_strings(excluded_stings,n_strings, string_length)
    unique_strings = Vector{String}(undef,n_strings)
    unique_strings[1] = unique_random_string(excluded_stings,string_length)
    for i in 2:n_strings
		# Not using push! but vcat to avoid mutation of excluded_stings argument.
    	unique_strings[i] = unique_random_string(vcat(unique_strings[1:i-1],excluded_stings),string_length)
    end
    return unique_strings
end



# Shift a cartesian index (i_1,...,i_n) to (i_1,...,i_j + r,...,i_n), where dimension = j and amount = +r
function shift_cartesian_index(index::CartesianIndex,dimension::Integer,amount::Integer)
    shift = zeros(Int64,length(index))
    shift[dimension] = amount
    return CartesianIndex(Tuple(index) .+ Tuple(shift))
end
















# Exported functions
####################################################################################################

"""
	create_grid(axis_ticks::AbstractArray...;initial_weight = 1.0, exclude_strings = [""],string_length = 10)
Create a multidimensional grid, where the `axis_ticks` define the corner points of the blocks.

For each dimension a separate array of axis-ticks is required. Each axis-ticks array must have at least 3 elements.

**Keywords**

* `initial_weight`: Initial weight for the blocks.
* `exclude_strings`: Strings that should not be used for the block names / keys.
* `string_length`: Length for the block names / keys.
"""
function create_grid(axis_ticks::AbstractArray...;initial_weight = 1.0, exclude_strings = [""],string_length = 10)
	# The axis_ticks define the corner-points. To avoid special cases in in the 1-dim case, 3 corner points, i.e. 2 blocks are required.
	for elm in axis_ticks
		if length(elm) < 3
			throw(DimensionMismatch("each axis must have at least 3 elements"))
		end
	end

	# Copy and sort axis_ticks to avoid mutation.
	sorted_axis_ticks = [sort(axis_ticks[i]) for i in 1:length(axis_ticks)]

	# Get multidimensional array of indices. Convenient for getting the intervals for the blocks.
	# axis_ticks define corners of blocks -> length -1.
	cartesian_indices = CartesianIndices(Tuple(length.(sorted_axis_ticks) .-1 )) 

	# Reshape the `unique_names` to the same multidimensional structure as `cartesian_indices`.
	unique_names = reshape(unique_random_strings(exclude_strings,length(cartesian_indices),string_length),size(cartesian_indices))


	# Get cuboids for the blocks.
	cuboids = [Cuboid([Interval(sorted_axis_ticks[dim][interval_index[dim]],sorted_axis_ticks[dim][interval_index[dim]+1]) for dim in 1:length(interval_index)]) for interval_index in cartesian_indices]

	# Create blocks.
	blocks = Block[]
	for grid_position in cartesian_indices
		neighbor_names = String[]
		for dim in 1:length(grid_position)
			# If not first element in a given dimension, add previous element as neighbor.
			if grid_position[dim] > 1
				push!(neighbor_names,unique_names[shift_cartesian_index(grid_position,dim,-1)])
			end
			# If not last element in a given dimension, add following element as neighbor.
			if grid_position[dim] < size(cartesian_indices)[dim]
				push!(neighbor_names,unique_names[shift_cartesian_index(grid_position,dim,+1)])
			end
		end
		push!(blocks,Block(unique_names[grid_position],cuboids[grid_position],neighbor_names,initial_weight))
	end


return Grid(Dict(zip(unique_names,blocks)))
end





"""
	create_grid(axis_ticks::AbstractArray;initial_weight = 1.0, exclude_strings = [""],string_length = 10)
Create a one-dimensional grid where the `axis_ticks` define the start/end points of the intervals.

There must be at least 3 elements in the axis_ticks array.

**Keywords**

* `initial_weight`: Initial weight for the intervals.
* `exclude_strings`: Strings that should not be used for the block names / keys.
* `string_length`: Length for the block names / keys.
"""
function create_grid(axis_ticks::AbstractArray;initial_weight = 1.0, exclude_strings = [""],string_length = 10)

	# Construction of one-dimensional grid more convenient with at least 3 start/end points i.e. 2 intervals.
	if length(axis_ticks) < 3
		throw(DimensionMismatch("the axis must have at least 3 elements"))
	end

	# Copy and sort axis_ticks to avoid mutation.
	sorted_axis_ticks = sort(axis_ticks)

	# Length -1 since n start/end points define n-1 intervals.
	unique_names = unique_random_strings(exclude_strings,length(sorted_axis_ticks)-1,string_length)

	blocks = OneDimBlock[]
	# The left-most block has only one neighbor at the right.
	push!(blocks,OneDimBlock(unique_names[1],Interval(sorted_axis_ticks[1], sorted_axis_ticks[2]), [unique_names[2]],initial_weight))
	# Middle blocks have two neighbors.
	for i in 2:length(sorted_axis_ticks)-2
		push!(blocks, OneDimBlock(unique_names[i], Interval(sorted_axis_ticks[i], sorted_axis_ticks[i+1]), [unique_names[i-1], unique_names[i+1]], initial_weight ))
	end
	# The right-most block has only one neighbor at the left.
	push!(blocks,OneDimBlock(unique_names[end],Interval(sorted_axis_ticks[end-1], sorted_axis_ticks[end]), [unique_names[end-1]],initial_weight))

	return OneDimGrid(Dict(zip(unique_names,blocks)))
end

