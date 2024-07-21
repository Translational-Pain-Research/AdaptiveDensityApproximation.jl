####################################################################################################
# Restriction of grids
####################################################################################################


export  get_slice, select_indices, restrict_domain!



# Internal functions
####################################################################################################


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
















# Exported functions
####################################################################################################



"""
	get_slice(grid::Grid, slice_selection)
Return a grid of blocks (from `grid`) that intersect with a slice defined by `slice_selection`.

3-dim example: the y-axis is defined by `slice_selection = [0,nothing,0]`, the y-z-plane at `x = 5` is defined by `slice_selection = [5,nothing,nothing]`, etc..
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
	select_indices(grid::OneDimGrid; lower::Real=-Inf,upper::Real=Inf)
Return indices of intervals with centers between `lower` and `upper`. The index order is the order of [`export_weights`](@ref) and [`export_all`](@ref)
"""
function select_indices(grid::OneDimGrid; lower::Real=-Inf,upper::Real=Inf)
	centers, volumes, weights = export_all(grid)
	return findall(x-> lower <= x <= upper, centers)
end


"""
	select_indices(grid::Grid; lower= [-Inf,...,-Inf],upper=[Inf, ..., Inf])
Return indices of intervals with centers between `lower` and `upper`. The index order is the order of [`export_weights`](@ref) and [`export_all`](@ref).
"""
function select_indices(grid::Grid; lower= [-Inf for i in 1:dimension(grid)],upper=[Inf for i in 1:dimension(grid)])
	centers, volumes, weights = export_all(grid)
	
	if !(length(lower)==length(upper) == length(centers[1]))
		throw(DimensionMismatch("Dimensions of the grid, the lower bounds or the upper bounds do not match!"))
	end

	inbounds = function(center,lower,upper)
		for i in eachindex(center)
			if !(lower[i]<= center[i]<=upper[i])
				return false
			end
		end
		return true
	end

	return findall(x-> inbounds(x,lower,upper), centers)
end













"""
	restrict_domain!(grid::OneDimGrid; 
		lower::Real = -Inf,
		upper::Real = Inf, 
		weight_distribution::Symbol = :none
	)

Restrict the domain of a grid to the domain defined by `lower` and `upper`.

* `weight_distribution = :linear`: If a block gets split up, the weight is rescaled w.r.t. the proportion of the block within the domain.
* `weight_distribution = :log`: If a block gets split up, the weight is rescaled w.r.t. the proportion of the block within the domain, as it appears in a logarithmically scaled plot.
"""
function restrict_domain!(grid::OneDimGrid; lower::Real = -Inf,upper::Real = Inf, weight_distribution::Symbol = :none)
	to_be_removed = String[]

	if upper < lower
		throw(DomainError("lower <= upper not satisfied!"))
	end

	for key in collect(keys(grid))
		# Interval is mutated. Keep the original interval to calculate the proportion inside the domain if needed.
		original_interval = grid[key].interval

		# Interval outside of the domain.
		if grid[key].interval[2] <= lower || grid[key].interval[1] >= upper
			push!(to_be_removed,key)
		end

		# Interval intersects domain from below.
		if grid[key].interval[1] < lower < grid[key].interval[2]
			grid[key].interval = Interval(lower, grid[key].interval[2])
		end

		# Interval intersects domain from above.
		if grid[key].interval[1] < upper < grid[key].interval[2]
			grid[key].interval = Interval(grid[key].interval[1],upper)
		end

		if weight_distribution == :linear
			grid[key].weight  *= volume(grid[key])/volume(original_interval)
		elseif weight_distribution == :log
			grid[key].weight  *= (log(grid[key].interval[2])-log(grid[key].interval[1]))/(log(original_interval[2])-log(original_interval[1]))
		end
	end

	for block_key in to_be_removed
		delete!(grid.grid,block_key)
	end

	for block in collect(values(grid))
		deleteat!(block.neighbors,findall(x-> x in to_be_removed, block.neighbors))
	end

	if length(grid) < 1
		@warn("Boundaries too restrictive, returning empty grid!")
	end
	
	return grid
end










"""
	restrict_domain!(grid::Grid;
		lower = [-Inf,...,-Inf],
		upper = [Inf,...,Inf],
		weight_distribution::Symbol = :none
	)

Restrict the domain of a grid to the domain defined by `lower` and `upper`.

* `weight_distribution = :linear`: If a block gets split up, the weight is rescaled w.r.t. the proportion of the block within the domain.
* `weight_distribution = :log`: If a block gets split up, the weight is rescaled w.r.t. the proportion of the block within the domain, as it appears in a logarithmically scaled plot.
"""
function restrict_domain!(grid::Grid;lower = [-Inf for i in 1:dimension(grid)], upper = [Inf for i in 1:dimension(grid)], weight_distribution::Symbol = :none)
	to_be_removed = String[]

	if length(lower) != length(upper)
		throw(DimensionMismatch("Lengths of boundaries do not match!"))
	end
	
	for i in eachindex(lower)
		if lower[i] > upper[i]
			throw(DomainError("lower <= upper not satisfied!"))
		end
	end


	for key in collect(keys(grid))
		# Define original interval to ease readability (no mutation of cuboid here).
		original_intervals = [grid[key].cuboid[dim] for dim in eachindex(lower)]
		# Mutation of cuboid not possible because of type restrictions (type change not allowed for intervals in Cuboid).
		new_intervals = Interval[grid[key].cuboid[dim] for dim in eachindex(lower)]
		for dim in eachindex(lower)

			# Interval outside of the domain.
			if original_intervals[dim][2] <= lower[dim] || original_intervals[dim][1] >= upper[dim]
				push!(to_be_removed,key)
			end

			# Interval intersects domain from below.
			if original_intervals[dim][1] < lower[dim] < original_intervals[dim][2]
				new_intervals[dim] = Interval(lower[dim], original_intervals[dim][2])
			end

			# Interval intersects domain from above.
			if original_intervals[dim][1] < upper[dim] < original_intervals[dim][2]
				new_intervals[dim] = Interval(original_intervals[dim][1],upper[dim])
			end

			if weight_distribution == :linear
				grid[key].weight  *= volume(new_intervals[dim])/volume(original_intervals[dim])
			elseif weight_distribution == :log
				grid[key].weight  *= (log(new_intervals[dim][2])-log(new_intervals[dim][1]))/(log(original_intervals[dim][2])-log(original_intervals[dim][1]))
			end
		end
		grid[key].cuboid = Cuboid(new_intervals)
	end

	for block_key in to_be_removed
		delete!(grid.grid,block_key)
	end

	for block in collect(values(grid))
		deleteat!(block.neighbors,findall(x-> x in to_be_removed, block.neighbors))
	end


	if length(grid) < 1
		@warn("Boundaries too restrictive, returning empty grid!")
	end
	
	return grid
end