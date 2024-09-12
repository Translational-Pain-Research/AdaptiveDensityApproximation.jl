# AdaptiveDensityApproximation

## About

[`AdaptiveDensityApproximation.jl`](https://github.com/Translational-Pain-Research/AdaptiveDensityApproximation.jl) introduces the types `OneDimGrid` and`Grid` that can be refined adaptively for the approximation of density functions. Simple calculations are implemented, e.g. the sum and product of approximated density coefficients or a rudimentary numerical integration of approximated densities. Integral models can be approximated for the inference of densities. In case of probability densities, empirical PDF and CDF functions can be constructed.


## Installation

The package can be installed with the following commands

```julia
using Pkg
Pkg.Registry.add()
Pkg.Registry.add(RegistrySpec(url = "https://github.com/Translational-Pain-Research/Translational-Pain-Julia-Registry"))
Pkg.add("AdaptiveDensityApproximation")
```
Since the package is not part of the `General` registry the commands install the additional registry `Translational-Pain-Julia-Registry` first.

After the installation, the package can be used like any other package:
```@example 1
using AdaptiveDensityApproximation
```
In the following, the methods of this package are illustrated with simple, 1-dimensional examples. For a full documentation of the methods, see the [API](api.md)

!!! tip "Tip: Plotting grids"
	This package does not include any plotting methods, to reduce the dependencies. However, the [`AdaptiveDensityApproximationRecipes.jl`](https://github.com/Translational-Pain-Research/AdaptiveDensityApproximationRecipes.jl) contains plotting recipes for [`Plots.jl`](https://docs.juliaplots.org/stable/). Assuming that the `Translational-Pain-Julia-Registry` is installed, the package can be installed like any other package:
	```julia
	using Pkg
	Pkg.add("AdaptiveDensityApproximationRecipes")
	```
	



## Construct a grid and approximate densities

The first step is to create a new one-dimensional grid with [`create_grid`](@ref). For this, axis-ticks need to be defined, i.e. the start/endpoints of the intervals:
```@example 1
using AdaptiveDensityApproximation, AdaptiveDensityApproximationRecipes, Plots
grid = create_grid(LinRange(0,2*pi,10))
```

The grid can be used to approximate a density with [`approximate_density!`](@ref):

```@example 1
approximate_density!(grid,sin)
plot(grid)
plot!(sin,color = :red, xlims = [0,2*pi], linewidth = 3, label = "sin(x)")
```

!!! tip "Tip: Approximation options"
	A density is approximated by evaluating the density-function at the center points of the grid. But in some cases, it can be desireable to approximate the density using different evaluation points. The following keywords allow to modify the approximation points:

	* `mode = :mean`: Use the average of the function values from the endpoints of the interval / corner points of the block.
	* `mode = :mesh`: Use the average of the function values from a mesh of intermediate points.
	* `mesh_size = n`: If `mode = :mesh` use `n` intermediate points (per dimension). The default is 4.
	
	It is also possible to approximate the area under the graph of a density (function value × block volume) by using `volume_normalization = true`.


## Accessing information of the grid

Essentially, a grid is just a collection of values (the weights), together with location information (the blocks of the grid). This data can be exported to allow for a convenient implementation of advanced calculations not covered by this package. The weights can be exported with [`export_weights`](@ref):
```@example 1
export_weights(grid)
```
Alternatively, the full information can be exported with [`export_all`](@ref):
```@example 1
centers, volumes, weights = export_all(grid)
```
The reverse direction, the import of weights is possible with [`import_weights!`](@ref):
```@example 1
import_weights!(grid, collect(1:9))
plot(grid)
```


!!! info "Order of blocks"
	For export and import, the intervals/blocks are ordered according to their center points. For multidimensional grids, the order is component wise (first dimension precedes second dimension precedes third dimension ...).

## Refine the grid

The [`refine!`](@ref) function subdivides the blocks that have the largest weight differences to their neighbors):

```julia
refine!(grid)
```

!!! info
	A block is subdivided into 2^dim equally-sized subdividing blocks. E.g. an interval is split in the middle into two intervals, a square is split into 4 quartering squares, etc.. 


The functions [`approximate_density!`](@ref) and [`refine!`](@ref) can be used together in a loop to refine the grid adaptively.
```@example 1
grid = create_grid([0,pi/2,pi,3*pi/2,2*pi])

animation = @animate for i in 1:30
	plot(grid)
	plot!(sin,color = :red, xlims = [0,2*pi], linewidth = 3, label = "sin(x)")
	approximate_density!(grid,sin)
	refine!(grid)
end
gif(animation,fps=2)
```


!!! tip "Tip: Custom variation and block selection"
	The refine process is a two-step process. First, each block is assigned a variation value. The default variation is the largest absolut weight difference to the neighboring blocks. Then, based on the variation values, the blocks that will be subdivided further get selected (largest variation value by default). However, it is possible to redefine the block variation assignment and the selection:

	* `block_variation`: Function to calculate the variation value for a block. Must use the following signature `(block_center,block_volume, block_weight, neighbor_center,neighbor_volumes, neighbor_weights)`.
	* `selection`: Function to select which blocks need to be refined, based on their variation values. Must have the signature `(variations)`  where `variations` is a one-dim array of the variation values.

!!! info "Weight splitting"
	The new subdividing blocks retain the weight of the original block. If `split_weights = true`, the weight of the original block is split up evenly between the subdividing blocks (i.e. divided by the number of subdividing blocks).


## Restriction of grid domain

For some applications it can be useful to restrict a grid. Consider, for example, a grid that approximates `x->x^2` on the domain `[-2,2]`:

```@example 1
grid = create_grid(LinRange(-2,2,50))
approximate_density!(grid,x->x^2)
plot(grid)
```
The grid domain can be restricted to e.g. `[0,1]` with [`restrict_domain!`](@ref):
```@example 1
restrict_domain!(grid,lower = 0, upper = 1)
plot(grid)
```




## Simple calculations: Sums, products and integrals

Some simple operations are pre-defined for grids. For example, the sum and the product of the weights can easily be obtained.
```@example 1
sum(grid)
```
It is also possible to apply a function to all weights before they get summed up / get multiplied together. Furthermore, the grid domain can be restricted temporarily (not mutating the grid).
```@example 1
prod(x-> log(x),grid, lower = 0.5, upper = 0.9)
```

A grid can also be used for the approximation of an integral. In the case of the restricted grid from above, approximating ``x\mapsto x^2`` on ``[0,1]``, the integral ``\int_0^{1} x^2\ dx = \frac{1}{3}`` can be approximated with [`integrate`](@ref):
```@example 1
integrate(grid)
```



## Advanced calculations: Integral models

A more flexible method of integration is the construction of integral models. Consider the general model
```math
	\int f(x,y,\varphi(y),...) \ dy
```
When the density ``\varphi`` is approximated by a grid, i.e. by blocks ``B_i`` with centers ``c_i``, block volumes ``V_i`` and weights (function values) ``\lambda_i = \varphi(c_i)``, the model can be approximated:
```math
	\int f(x,\tau,\varphi(y),...) \ dy \approx \sum_{i} f(x,c_i, \lambda_i,\ldots)\cdot V_i \ .
```
As simple example, consider `f(x,y,φ(y)) = cos(y * x) * φ(y) ` with `φ(y) = sin(y)` for the domain `[0,2π]`:
```math
\int_0^{2\pi} \cos(y\cdot x)  \cdot \text{sin}(y) \ dy \ .
```
First, we construct a grid with domain `[0,2π]` and approximate the density `sin(y)`:
```@example 1
grid = create_grid(LinRange(0,2*pi,30))
approximate_density!(grid,sin)
nothing # hide
```
Next, we create the integral kernel `f` and create the approximated model with [`integral_model`](@ref):
```@example 1
f(x,y,φ) = cos(y*x)*φ
approx_model,weights, block_functions = integral_model(grid,f)
nothing # hide
```
Finally, we can evaluate the model at `x = 1, λ = weights`
```@example 1
approx_model(1,weights)
```
The result can be checked analytically in this case:
```math
\int_0^{2\pi} \cos(y\cdot 1)  \cdot \text{sin}(y) \ dy = 0\ .
```

!!! tip "Approximated model and density estimation"
	The approximated model function `approx_model`  is a function of `(x,weights,...)`, where `weights` are the weights of the gird. However, instead of the grid `weights` any other array of the same length and data type can be used as argument. This allows to estimate a density by fitting the approximated model to data.

!!! tip "individual block functions and partial derivatives"
	The `block_functions` contain the functions for the individual blocks. That is, `block_functions` is an array of functions
	```math
	\left[(x,\lambda,\ldots) \longrightarrow V_i \cdot g(x,c_j,\lambda_j,\ldots) \qquad \text{for}\quad  i\quad  \text{in}\quad  1\colon n_{\text{blocks}} \right]
	```
	Instead of the integral kernel `f`, the optional third argument `g` is used: `integrate_model(grid,f,g)`. If no third argument is provided, the default case is `g=f`. This optional third argument can be used to construct the partial derivatives of the approximated model w.r.t. the parameters ``\lambda_j``, by constructing `g` such that
	```math
	g(x,y,\varphi,\ldots) = \frac{\partial f(x,y,\varphi,\ldots)}{\partial \varphi} 
	```
	This leads to the following `block_functions`:
	```math
	\left[(x,\lambda,\ldots) \longrightarrow V_i \cdot \left. \frac{\partial f(x,y,\varphi,\ldots)}{\partial \varphi}\right|_{(x,y,\varphi,\ldots) = (x,c_j,\lambda_j,\ldots)} \qquad \text{for}\quad  i\quad  \text{in}\quad  1\colon n_{\text{blocks}} \right]
	```
	It can easily be checked that these functions are the partial derivatives w.r.t. the parameters ``\lambda_j`` of the approximated model:
	```math
	\frac{\partial}{\partial \lambda_j} \sum_i V_i f(x,c_j,\lambda_j,\ldots) = V_i \frac{\partial}{\partial \lambda_j}  f(x,c_j,\lambda_j,\ldots) \equiv V_i \cdot \left. \frac{\partial f(x,y,\varphi,\ldots)}{\partial \varphi}\right|_{(x,y,\varphi,\ldots) = (x,c_j,\lambda_j,\ldots)}
	```




## PDF and CDF

When the grid approximates a probability density, i.e. a positive density function, approximated PDF anc CDF functions can be obtained with [`get_pdf`](@ref) and [`get_cdf`](@ref). For example, consider a normal distribution:

```@example 1
p(x) = 1/sqrt(2*pi) * exp(-x^2/2)
grid = create_grid(LinRange(-10,10,100))
approximate_density!(grid,p)
plot(grid)
```

Then the approximated CDF is

```@example 1
cdf = get_cdf(grid)

plot(cdf, fill = 0, legend = :none)
```

!!! warning
	The functions [`get_pdf`](@ref) and [`get_cdf`](@ref) do not check if the weights of the blocks are positive. Negative values can lead to unexpected behavior, e.g. division by zero because of the normalization `1/sum(weights)`.

## Simple 2-dim example

In general, all methods introduced so far are defined for grids of arbitrary dimensions (except for plotting recipes):

```julia
using AdaptiveDensityApproximation, Plots

grid = create_grid([0,pi,2*pi],[0,pi,2pi])
f(x) = sin(x[1])^2 + cos(x[2])^2

animation = @animate for i in 1:100
	plot(grid)
	approximate_density!(grid,f)
	refine!(grid)
end
gif(animation, fps = 4)
```
![](images/simple-2-dim-example.gif)

It is possible to get a lower-dimensional slice from a higher-dimensional grid with [`get_slice`](@ref). For the previous 2-dim example a slice along the `x`-axis at `y=3` can be obtained as follows:


```@example 1
grid = create_grid([0,pi,2*pi],[0,pi,2pi]) #hide
f(x) = sin(x[1])^2 + cos(x[2])^2 #hide

for i in 1:100 #hide
	approximate_density!(grid,f) #hide
	refine!(grid) #hide
end #hide

slice = get_slice(grid,[nothing,3])
plot(slice)
```