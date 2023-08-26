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
	sum(grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
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
	sum(f::Function,grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
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
	prod(grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
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
	prod(f::Function,grid::Union{OneDimGrid, Grid}; lower = nothing, upper = nothing, weight_distribution::Symbol = :none)
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
Return the sum of `volume × weight` for the intervals/blocks.

When the grid approximates a density `φ` with the weights of the intervals/blocks, `integrate(grid)` approximates the integral of the density over the grid domain: `∫_grid φ dV`.
"""
function integrate(grid::Union{OneDimGrid,Grid})
	return sum(grid[key].weight * volume(grid[key]) for key in keys(grid))
end



"""
	integral_model(grid,f::Function, g::Function = f)
Create a model for the integral `∫_grid f(x,y,φ(y),...) dy`. Returns

* model function: `(x,λ,args...) -> ∑_i block[i].volume × f(x,block[i].center,λ[i],args...)`
* initial parameter based on block weights: `λ_0 = [block.weight for block in grid]`
* components of the sum as array of functions: `[(x,λ,args...) -> block[i].volume × g(x,block[i].center,λ[i],args...) for i]`

The functions `f` and `g` should have the arguments `(x,center,weight,args...)`.  

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









