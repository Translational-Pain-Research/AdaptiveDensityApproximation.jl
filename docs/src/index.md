# AdaptiveDensityApproximation

## About

This package introduces the `Grid` and `OneDimGrid` types that approximate density functions. The grids can be refined adaptively, i.e. depending on the  location of the strongest density variation.


## Installation

This package is not in the general registry and needs to be installed from the GitHub repository by:

```@julia
using Pkg
Pkg.add(url="https://github.com/AntibodyPackages/AdaptiveDensityApproximation")
```

After the installation, the package can be used like any other package:
```@example 1
using AdaptiveDensityApproximation
```

!!! tip "Tip: Plotting grids"
	This package does not include any plotting methods, to reduce the dependencies. However, the package `AdaptiveDensityApproximationRecipes` contains plotting recipes for `Plots.jl`. Again, the package is not in the general registry and needs to be installed from the GitHub repository:
	```@julia
	using Pkg
	Pkg.add(url="https://github.com/AntibodyPackages/AdaptiveDensityApproximationRecipes")
	```

## 1-dim example

### Construct grid and approximate densities

The first step is to create a new one-dimensional grid. For this, axis-ticks need to be defined, i.e. the start/endpoints of the intervals:
```@example 1
using AdaptiveDensityApproximation, AdaptiveDensityApproximationRecipes, Plots
grid = create_grid(LinRange(0,2*pi,10))
```

The grid can be used to approximate a function `f` with `approximate_density!(grid,f)`:

```@example 1
approximate_density!(grid,sin)
plot(grid)
plot!(sin,color = :red, xlims = [0,2*pi], linewidth = 3)
```

### Refine the grid

The grid can be refined (in the blocks that have the largest weight differences to their neighbors) with:

```julia
refine!(grid)
```

The functions `approximate_density!` and `refine!` can be used together in a loop to refine the grid adaptively.
```@example 1
grid = create_grid([0,pi/2,pi,3*pi/2,2*pi])

animation = @animate for i in 1:30
	plot(grid)
	approximate_density!(grid,sin)
	refine!(grid)
end
gif(animation,fps=2)
```

### Integration and integral models

A grid can also be used for an approximation of an integral. In the case of the adaptively refined grid from above, the integral ``\int_0^{2\pi} sin(x)\ dx`` is approximated:
```@example 1
integrate(grid)
```



A more flexible method of integration is the construction of integral models. Consider the general model
```math
	\int f(x,\tau,\varphi(\tau),...) \ d\tau
```
for a density function ``\varphi``. When the density function is approximated by a grid, i.e. by intervals ``I_j`` with centers ``c(I_j)``, volumes ``\text{vol}(I_j)`` and heights ``h(I_j)\approx \varphi(c(I_j))``, the model can be approximated with
```math
	\int f(x,\tau,\varphi(\tau),...) \ d\tau \approx \sum_{j} f(x,c(I_j), h(I_j),\ldots)\cdot \text{vol}(I_j) \ .
```
In general, the implementation of such a model requires a function `f(x,τ,φ(τ),...)` and a grid that approximates the density `φ`. The model can then be obtained with `integral_model(grid,f)`. More precisely:

```@example 1
@doc integral_model #hide
```

```@raw html
<br>
```


For example, consider `f(x,τ,φ(τ)) = cos(τ * x) * φ(τ) ` for `φ(τ) = sin(τ)` on `[0,2π]`:
```math
\int_0^{2\pi} \cos(\tau\cdot x)  \cdot \text{sin}(\tau) \ d\tau \ .
```
In particular, it holds that:
```math
\int_0^{2\pi} \cos(\tau\cdot 1)  \cdot \text{sin}(\tau) \ d\tau = 0\ .
```
For this, we can again use the previous `grid` that approximated `sin` on `[0,2π]`:
```@example 1
f(x,τ,φ) = cos(τ*x)*φ
model,weights, components = integral_model(grid,f)
model(1,weights)
```

### Numeric PDF and CDF

When the grid approximates a probability density, i.e. a positive density function, numeric PDF anc CDF functions can be obtained as julia functions.

```@example 1
p(x) = 1/sqrt(2*pi) * exp(-x^2/2)
grid = create_grid(LinRange(-10,10,100))
approximate_density!(grid,p)
plot(grid)
```

The numeric pdf can be obtained with 

```@example 1
@doc get_pdf #hide
```

```@raw html
<br>
```

The numeric cdf can be obtained with 

```@example 1
@doc get_cdf #hide
```

```@raw html
<br>
```

For example
```@example 1
cdf = get_cdf(grid)

plot(cdf, fill = 0, legend = :none)
```

!!! warning
	The function `get_pdf` and `get_cdf` do not check if the weights of the blocks are positive. Negative values can lead to unexpected behavior, e.g. division by zero because of the normalization `1/sum(weights)`.

## Simple 2-dim example

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