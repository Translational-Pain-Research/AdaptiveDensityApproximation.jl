####################################################################################################
# Density approximation
####################################################################################################


export  dimension, approximate_density!, get_pdf, get_cdf




# Omit docstring for dispatch version (dimension function behaves always the same).
function dimension(grid::OneDimGrid)
	return 1
end

"""
	dimension(grid::Union{OneDimGrid,Grid})
Return the dimension of the `grid`. 
"""
function dimension(grid::Grid)
	key_list = collect(keys(grid))
	return length(grid[key_list[1]].cuboid.intervals)
end



"""
	approximate_density!(grid::Union{OneDimGrid,Grid},f::Function; 
		mode = :center,
		mesh_size = 4,
		volume_normalization = false
	)
	
Approximate the density function `f` with the `grid`, changing the weights to the function values and return the mutated grid.

* `mode = :center`: Evaluate the density function in the center of the interval/block.
* `mode = :mean`: Evaluate the density function at all corner points of the interval/block and use the mean value.
* `mode = :mesh`: Evaluate the density function at all mesh points of the interval/block and use the mean value.
* `mesh_size = 4`: Number of block discretization points in each dimension. Only applicable to `mode = :mesh`.
* `volume_normalization = false`: If `true` the density value is normalized to the interval length / block volume (`weight = value × volume`).
"""
function approximate_density!(grid::Union{OneDimGrid,Grid},f::Function; mode = :center, mesh_size::Integer = 4, volume_normalization::Bool = false)
	for block in values(grid)
		if mode == :mean
			corner_points = corners(block)
			block.weight = sum(f(corner_point) for corner_point in corner_points) / length(corner_points) 
		elseif mode == :center
			block.weight = f(center(block))
		elseif mode == :mesh
			mesh_points = intermediate_points(block,mesh_size)
			block.weight = sum(f(mesh_point) for mesh_point in mesh_points) / length(mesh_points)
		end
		if volume_normalization
			block.weight *= volume(block)
		end
	end
	return grid
end





"""
	get_pdf(grid::Union{OneDimGrid,Grid}; normalize::Bool = true)
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
	get_cdf(grid::Union{OneDimGrid,Grid};normalize::Bool = true)
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
