####################################################################################################
# Type definitions and base methods
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









# Extension of Base methods
####################################################################################################

# Dictionary modifying methods are not defined for grid types to prevent accidental mutation!

# Direct access to blocks in a Grid.
getindex(G::Union{OneDimGrid,Grid},ind) = G.grid[ind]

# Since length is already imported, and since users cannot accidentally modify the grid with it.
length(G::Union{OneDimGrid,Grid}) = length(G.grid)

# Direct access to key iterator.
keys(G::Union{OneDimGrid,Grid}) = keys(G.grid)

# Direct access to block iterator.
values(G::Union{OneDimGrid,Grid}) = values(G.grid)