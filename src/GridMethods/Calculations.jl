####################################################################################################
# Calculations (sum, product and integrals)
####################################################################################################

# sum and product are exported by default as base methods.
export  integrate, integral_model




# Internal functions
####################################################################################################


# These are always the same steps for all versions of sum and product.
function sum_product_kernel(grid::Union{OneDimGrid,Grid},lower,upper, weight_distribution)
	if isnothing(lower) && isnothing(upper)
		return export_weights(grid)
	end

	temporary_grid = deepcopy(grid)

	if isnothing(lower)
		return export_weights(restrict_domain!(temporary_grid, upper = upper, weight_distribution = weight_distribution))
	elseif isnothing(upper)
		return export_weights(restrict_domain!(temporary_grid, lower = lower, weight_distribution = weight_distribution))
	else
		return export_weights(restrict_domain!(temporary_grid, lower = lower, upper = upper, weight_distribution = weight_distribution))
	end

end






# Exported functions
####################################################################################################

"""
	sum(grid::Union{OneDimGrid, Grid}; 
		lower = nothing, 
		upper = nothing, 
		weight_distribution::Symbol = :none
	)

Return the sum of all weights.

* `lower`, `upper` and `weight_distribution` can be used to restrict the domain, similar to [`restrict_domain!`](@ref). This does not mutate the `grid`.
* Too restrictive boundaries (empty grid) raise a warning and the default value 0 is returned.
"""
function sum(grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
	values = sum_product_kernel(grid,lower,upper,weight_distribution)
	if isempty(values)
		0
	else
		return sum(values)
	end
end


"""
	sum(f::Function,grid::Union{OneDimGrid, Grid}; 
		lower = nothing, 
		upper = nothing, 
		weight_distribution::Symbol = :none
	)

Return the sum of `f(weight)` for all weights.

* `lower`, `upper` and `weight_distribution` can be used to restrict the domain, similar to [`restrict_domain!`](@ref). This does not mutate the `grid`.
* Too restrictive boundaries (empty grid) raise a warning and the default value 0 is returned.
"""
function sum(f::Function,grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
	values = sum_product_kernel(grid,lower,upper,weight_distribution)
	if isempty(values)
		0
	else
		return sum(f.(values))
	end
end


"""
	prod(grid::Union{OneDimGrid, Grid}; 
		lower = nothing,
		upper = nothing,
		weight_distribution::Symbol = :none
	)

Return the product of all weights.

* `lower`, `upper` and `weight_distribution` can be used to restrict the domain, similar to [`restrict_domain!`](@ref). This does not mutate the `grid`.
* Too restrictive boundaries (empty grid) raise a warning and the default value 1 is returned.
"""
function prod(grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
	values = sum_product_kernel(grid,lower,upper,weight_distribution)
	if isempty(values)
		1
	else
		return prod(values)
	end
end


"""
	prod(f::Function,grid::Union{OneDimGrid, Grid};
		lower = nothing,
		upper = nothing,
		weight_distribution::Symbol = :none
	)

Return the product of `f(weight)` for all weights.

* `lower`, `upper` and `weight_distribution` can be used to restrict the domain, similar to [`restrict_domain!`](@ref). This does not mutate the `grid`.
* Too restrictive boundaries (empty grid) raise a warning and the default value 1 is returned.
"""
function prod(f::Function,grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
	values = sum_product_kernel(grid,lower,upper,weight_distribution)
	if isempty(values)
		1
	else
		return prod(f.(values))
	end
end










"""
	integrate(grid)
Return the sum over all intervals/blocks of `volume × weight`.

When the grid weights approximate a density `φ`, `integrate(grid)` approximates the integral of the density over the grid domain: `∫_grid φ dV`. This does not apply, if the gird weights already approximate the area/volume under the density (see `volume_normalization` for [`approximate_density!`](@ref)).
"""
function integrate(grid::Union{OneDimGrid,Grid})
	return sum(grid[key].weight * volume(grid[key]) for key in keys(grid))
end



"""
	integral_model(grid,f::Function, g::Function = f)
Create an approximation for the integral model `∫_grid f(x,y,φ(y),args...) dy`. Returns

* the approximated model (function).
* the grid weights as initial parameters (array).
* individual block functions using `g` instead of `f` (array of functions).

Let the grid approximate the density `φ`. That is, the weight of blocks are characteristic density values for the blocks. For example, `λ_i = φ(c_i)` where `c_i` are the centers of the blocks. Furthermore let `V_i` denote the volumes of the blocks. Then:

* the returned approximated model is: `(x,λ,args...) -> ∑_i V_i ⋅ f(x,c_i,λ_i,...)`
* the returned parameters are: `[λ_1,...,λ_n]`
* the individual block functions are: `[(x,λ,args...) -> V_i ⋅ g(x,c_i,λ_i,...) for i = 1:number_of_blocks]`

Using an optional integral kernel function `g`, allows to obtain modified functions for the individual blocks (if `g` is not provided the default case is `g=f`). The functions `f` and `g` should have the arguments `(x,center,weight,args...)`. This can be useful if one wants to obtain partial derivatives of the approximated model. For further details see [Advanced calculations: Integral models](@ref Advanced-calculations:-Integral-models) 
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









