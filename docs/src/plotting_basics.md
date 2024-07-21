# Plotting grids

[`AdaptiveDensityApproximationRecipes.jl`](https://github.com/AntibodyPackages/AdaptiveDensityApproximationRecipes.jl) defines plotting recipes for [`Plots.jl`](https://docs.juliaplots.org/stable/), providing simple visualizations for 2-dim `Grid` objects and `OneDimGrid` objects.

If the registry `AntibodyPackagesRegistry` is installed, `AdaptiveDensityApproximationRecipes.jl` can be installed like any other package
```julia
using Pkg
Pkg.add("AdaptiveDensityApproximationRecipes")
```
Otherwise, install the `AntibodyPackagesRegistry` first
```julia
using Pkg
Pkg.Registry.add()
Pkg.Registry.add(RegistrySpec(url = "https://github.com/AntibodyPackages/AntibodyPackagesRegistry"))
```

To illustrate the plotting of grids, a `OneDimGrid` object and a `Grid` object need to be constructed

```@example 2
using AdaptiveDensityApproximation
one_dim_grid = create_grid(LinRange(0,2*pi,20))
approximate_density!(one_dim_grid,sin)

two_dim_grid = create_grid(LinRange(0,2*pi,20),LinRange(0,2pi,20))
approximate_density!(two_dim_grid, x -> sin(x[1])^2 + cos(x[2])^2)
nothing #hide
```

With `AdaptiveDensityApproximationRecipes.jl` and `Plots.jl`, the grids can easily be plotted

```@example 2
using AdaptiveDensityApproximationRecipes, Plots
plot(one_dim_grid)
```

```@example 2
plot(two_dim_grid)
```
