####################################################################################################
# Type definitions
####################################################################################################



# Container struct for one-dimensional grids -> more convenient dispatch.
mutable struct OneDimGrid{GridType}
	grid::GridType

	function OneDimGrid(grid_dict::T) where {T <: AbstractDict{S,B} where {S <: AbstractString, B <: OneDimBlock}}
		return new{typeof(grid_dict)}(grid_dict)
	end
end





# Container struct for multidimensional grids -> more convenient dispatch.
mutable struct Grid{GridType}
	grid::GridType

	function Grid(grid_dict::T) where {T <: AbstractDict{S,B} where {S <: AbstractString, B <: Block}}
		return new{typeof(grid_dict)}(grid_dict)
	end
end












####################################################################################################
# Associated functions
####################################################################################################





# Extension of Base methods
####################################################################################################

# Direct access to blocks in a Grid.
getindex(G::Union{OneDimGrid,Grid},ind) = G.grid[ind]

# Since length is already imported, and since users cannot accidentally modify the grid with it.
length(G::Union{OneDimGrid,Grid}) = length(G.grid)

# Direct access to key iterator.
keys(G::Union{OneDimGrid,Grid}) = keys(G.grid)

# Direct access to block iterator.
values(G::Union{OneDimGrid,Grid}) = values(G.grid)



# Dictionary modifying methods are not defined for grid types to prevent accidental mutation!















# Common external constructor and associated methods
####################################################################################################

export create_grid

# Create a unique random string (w.r.t. `excluded_strings`) with length `string_length`.
function unique_random_string(excluded_strings,string_length)
    candidate = randstring(string_length)
    while candidate in excluded_strings
        candidate = randstring(string_length)
    end
    return candidate
end

# Create 'n_string' unique random strings of length 'string_length', excluding the `excluded_stings`.
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






















# Internal functions
####################################################################################################

# Use create_grid method to subdivide block.
@inline function create_subdividing_grid(block::OneDimBlock,exclude_strings)
	axis_ticks =  [block.interval.left, center(block), block.interval.right]
	return create_grid(axis_ticks, exclude_strings = exclude_strings, initial_weight = block.weight, string_length = length(block.name))
end

# Dispatch version..
@inline function create_subdividing_grid(block::Block, exclude_strings)
	axis_ticks =  [[block.cuboid[dim].left, center(block)[dim], block.cuboid[dim].right] for dim in 1:length(block.cuboid)]
	return create_grid(axis_ticks..., exclude_strings =  exclude_strings, initial_weight = block.weight, string_length = length(block.name))
end


# Default function to calculate a variation.
@inline function default_block_variation(block_center,block_volume,block_weight, neighbor_centers,neighbor_volumes,neighbor_weights)
	return maximum(abs.(block_weight .- neighbor_weights))
end


# Check if a block intersects with a slice by checking the axis values.
@inline function block_in_slice(block::Block, axis_dimensions, axis_values)
	for i in 1:length(axis_values)
		# Condition that there is no intersection in respective dimension.
		if axis_values[i] < block.cuboid[axis_dimensions[i]].left || axis_values[i] > block.cuboid[axis_dimensions[i]].right
			return false
		end
	end
	return true
end




















# Methods for grids
####################################################################################################

export  export_weights, export_all, import_weights!, approximate_density!, subdivide!, refine!, integrate, integral_model, get_pdf, get_cdf, get_slice


"""
	export_all(grid)
Return one-dim arrays: `centers, volumes, weights`.

The arrays are sorted and exported by centers.
"""
function export_all(grid::Union{OneDimGrid,Grid})
	grid_keys = collect(keys(grid))
	centers = [center(grid[key]) for key in grid_keys]
	volumes = [volume(grid[key]) for key in grid_keys]
	weights = [grid[key].weight for key in grid_keys]
	permutation = sortperm(centers)
	return centers[permutation], volumes[permutation], weights[permutation]
end



"""
	export_weights(grid)
Return a one-dim array containing the weights of the intervals/blocks.

The intervals/blocks are sorted by their centers. The weights are exported in this order.
"""
function export_weights(grid::Union{OneDimGrid,Grid})
	return export_all(grid)[3]
end




"""
	import_weights!(grid, weights)
Import weights and return the mutated grid.

The intervals/blocks are sorted by their centers. The weights are imported in this order.
"""
function import_weights!(grid::Union{OneDimGrid,Grid}, weights)
	grid_keys = sort(collect(keys(grid)))
	if length(grid_keys) != length(weights)
		throw(DimensionMismatch("The number of blocks in the grid and the number of weights to be imported do not match"))
	end
	centers = [center(grid[key]) for key in grid_keys]
	permutation = sortperm(centers)
	for i in 1:length(permutation)
		grid[grid_keys[permutation[i]]].weight = weights[i]
	end
	return grid
end


"""
	approximate_density!(grid,f::Function; mode = :center, mesh_size = 4)
Approximate the density function `f` with the grid, changing the weights to the function values. Return the mutated grid.

* `mode = :center`: Evaluate the density function in the center of the interval/block.
* `mode = :mean`: Evaluate the density function at all corner points of the interval/block and use the mean value.
* `mode = :mesh`: Evaluate the density function at all mesh points of the interval/block and use the mean value.

* `mesh_size = 4`: Number of block discretization points in each dimension. Only applicable to `mode = :mesh`.
"""
function approximate_density!(grid::Union{OneDimGrid,Grid},f::Function; mode = :center, mesh_size::Integer = 4)
	if mode == :mean
		for block in values(grid)
			corner_points = corners(block)
			block.weight = sum(f(corner_point) for corner_point in corner_points) / length(corner_points)
		end
	elseif mode == :center
		for block in values(grid)
			block.weight = f(center(block))
		end
	elseif mode == :mesh
		for block in values(grid)
			mesh_points = intermediate_points(block,mesh_size)
			block.weight = sum(f(mesh_point) for mesh_point in mesh_points) / length(mesh_points)
		end
	end
	return grid
end





"""
	subdivide!(grid,block_name::AbstractString)
Split the block with name `block_name` into `2^dim` sub-blocks. Return the mutated grid.
"""
function subdivide!(grid::Union{OneDimGrid,Grid},block_name::AbstractString)

	block_to_subdivide = grid[block_name]

	subdividing_grid = create_subdividing_grid(block_to_subdivide,collect(keys(grid)))

	# Add neighbors form the block_to_subdivide to the subdividing_blocks and vice versa.
	for subdividing_block in values(subdividing_grid)
		for neighbor_name in block_to_subdivide.neighbors
			if check_neighboring(subdividing_block,grid[neighbor_name])
				push!(subdividing_block.neighbors, neighbor_name)
				push!(grid[neighbor_name].neighbors,subdividing_block.name)
			end
		end
	end
	
	# Also remove the block_to_subdivide from neighbor lists.
	for neighbor_names in block_to_subdivide.neighbors
		deleteat!(grid[neighbor_names].neighbors, findall(x-> (x == block_name),grid[neighbor_names].neighbors ))
	end

	# Dict mutating functions not defined for grids -> explicitly call grid.grid.
	delete!(grid.grid,block_name)
	merge!(grid.grid,subdividing_grid.grid)
	return grid
end


"""
	refine!(grid; block_variation::Function = default_block_variation, selection::Function = maximum)
Subdivide intervals/blocks in a grid based on the respective variations. Return the mutated grid and the indices of subdivided (i.e. new) blocks (indices w.r.t arrays obtained from [`export_weights`](@ref) and [`export_all`](@ref)).

By default the variation of a block is the largest difference in weights w.r.t. to its neighbors. The blocks to be subdivided are those that have the largest variation. If several blocks have the same variation, all those blocks are subdivided.

**Changing the selection of blocks**

* `block_variation`: Function to calculate the variation value for a block. Must use the following signature `(block_center,block_volume, block_weight, neighbor_center,neighbor_volumes, neighbor_weights)`.
* `selection`: Function to select the appropriate variation value(s) from. Must have the signature `(variations)`  where variations is a one-dim array of the variation values.
"""
function refine!(grid::Union{OneDimGrid,Grid}; block_variation::Function = default_block_variation, selection::Function = maximum)
	# Get centers before refinements.
	old_centers = export_all(grid)[1]

	# Explicit array of keys to select names based on indices later on.
	block_names = collect(keys(grid))
	# Get variations associated to blocks (in the order of block_names).
	block_variations = [block_variation(center(grid[key]),volume(grid[key]), grid[key].weight, [center(grid[neighbor]) for neighbor in grid[key].neighbors], [volume(grid[neighbor]) for neighbor in grid[key].neighbors], [grid[neighbor].weight for neighbor in grid[key].neighbors]) for key in block_names]
	# Select the most appropriate variation (depending on implementation of `selection`).
	selected_variation = selection(block_variations)
	# Find the blocks to be refined by finding the positions where the selected variation occurs.
	blocks_to_refine = block_names[findall(x -> (x in selected_variation), block_variations)]
	
	for block in blocks_to_refine
		subdivide!(grid, block)
	end

	# Get centers after refinements
	new_centers = export_all(grid)[1]

	return grid, findall(x-> !(x in old_centers), new_centers)
end

"""
	integrate(grid)
Return the sum of `volume × weight` for the intervals/blocks.

When the grid approximates a density `φ` with the weights of the intervals/blocks, `integrate(grid)` approximates the integral of the density over the grid domain: `∫_grid φ dV`.
"""
function integrate(grid::Union{OneDimGrid,Grid})
	return sum(grid[key].weight * volume(grid[key]) for key in keys(grid))
end






"""
	integral_model(grid,f::Function, g::Function = f)
Create a model for the integral `∫_grid f(x,y,φ(y),...) dy`. Returns

* model function: `(x,λ,...) -> ∑_i block[i].volume × f(x,block[i].center,λ[i],...)`
* initial parameter based on block weights: `λ_0 = [block.weight for block in grid]`
* components of the sum as array of functions: `[(x,λ...) -> block[i].volume × g(x,block[i].center,λ[i],...) for i]`

The functions `f` and `g` should have the arguments `(x,center,weight,...)`.  

**Partial derivatives**

The optional function `g` can be used to obtain the partial derivatives of the model function w.r.t. `λ` as array of functions. For this, construct `g` such that

	g(x,c,w) = ∂_w f(x,c,w)
"""
function integral_model(grid::Union{OneDimGrid,Grid},f::Function, g::Function = f)
	centers,volumes, weights = export_all(grid)

	model = let V = volumes, C = centers
		@inline function(x,λ,y...)
			return sum(V[i] * f(x,C[i],λ[i],y...) for i in 1:length(V))
		end
	end

	component_functions = Function[]
	for i in 1:length(centers)
		∂_i =  let V = volumes, C = centers
			@inline function(x,λ,y...)
				return V[i]*g(x,C[i],λ[i],y...)
			end
		end
		push!(component_functions,∂_i)
	end

	return (model,weights,component_functions)
end


"""
	get_slice(grid::Grid, slice_selection)
Return a grid of blocks (from `grid`) that intersect with a slice defined by `slice_selection`.

For example: the y-axis is defined by `slice_selection = [0,nothing,0]`, the y-z-plane at `x = 5` is defined by `slice_selection = [5,nothing,nothing]`, etc..
"""
function get_slice(grid::Grid, slice_selection)
	slice_dimensions = [dim for dim in 1:length(slice_selection) if isnothing(slice_selection[dim])]
	axis_value_dimensions = [dim for dim in 1:length(slice_selection) if !isnothing(slice_selection[dim])]
	axis_values = slice_selection[axis_value_dimensions]
	new_keys = String[]
	
	# Collect keys of blocks that intersect with the slice.
	for key in keys(grid)
		if block_in_slice(grid[key],axis_value_dimensions,axis_values)
			push!(new_keys,key)
		end
	end

	# Create sliced blocks and return corresponding OneDimBlock/Grid.
	if length(slice_dimensions) == 1
		# Additional splatting since A[[i]] returns an array. Pick only neighbors that also belong to sliced grid, i.e. to new_keys.
		new_blocks = [OneDimBlock(key,grid[key].cuboid[slice_dimensions]...,[neighbor for neighbor in grid[key].neighbors if neighbor in new_keys],grid[key].weight) for key in new_keys]
		return OneDimGrid(Dict(zip(new_keys,new_blocks)))
	else
		# Pick only cuboid intervals in slice_dimensions. Pick only neighbors that also belong to sliced grid, i.e. to new_keys.
		new_blocks = [Block(key,Cuboid(grid[key].cuboid[slice_dimensions]),[neighbor for neighbor in grid[key].neighbors if neighbor in new_keys],grid[key].weight) for key in new_keys]
		return Grid(Dict(zip(new_keys,new_blocks)))
	end

end






"""
	get_pdf(grid;normalize::Bool = true)
Return the discrete empirical pdf function of a grid. For this, the grid is understood as histogram, where the blocks are the bins, and the weights are the corresponding values. If `normalize = true` the values are normalized s.t. the sum of all values is 1.
"""
function get_pdf(grid::Union{OneDimGrid,Grid};normalize::Bool = true)
	blocks = collect(values(grid))

	if normalize
		normalization = sum(export_weights(grid))
	else
		normalization = 1
	end

	return let blocks = blocks, normalization = normalization
		@inline function(x) 
			indices = findall(λ-> in_block(x,λ), blocks)
			if isempty(indices)
				return 0
			else
				return sum(blocks[ind].weight for ind in indices) / (length(indices) * normalization)
			end
		end
	end
end







"""
	get_cdf(grid;normalize::Bool = true)
Return the discrete empirical cdf function of a grid. For this, the grid is understood as histogram, where the blocks are the bins, and the weights are the corresponding values. If `normalize = true` the values are normalized s.t. the sum of all values is 1.
"""
function get_cdf(grid::Union{OneDimGrid,Grid};normalize::Bool = true)
	blocks = collect(values(grid))

	if normalize
		normalization = sum(export_weights(grid))
	else
		normalization = 1
	end

	return let blocks = blocks, normalization = normalization
		@inline function(x) 
			indices = findall(λ-> above_block(x,λ), blocks)
			if isempty(indices)
				return 0
			else
				return sum(blocks[ind].weight for ind in indices) / normalization
			end
		end
	end
end
