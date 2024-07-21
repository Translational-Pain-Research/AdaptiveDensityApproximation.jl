# Plotting options

Most keywords from `Plots.jl` are supported. Furthermore, the following options can be used to change the appearance of gird plots (using the grids from [Plotting basics](@ref Plotting-grids) for the examples):


```@example 3
using AdaptiveDensityApproximation, AdaptiveDensityApproximationRecipes, Plots #hide
one_dim_grid = create_grid(LinRange(0,2*pi,20)) #hide
approximate_density!(one_dim_grid,sin) #hide
two_dim_grid = create_grid(LinRange(0,2*pi,20),LinRange(0,2pi,20)) #hide
approximate_density!(two_dim_grid, x -> sin(x[1])^2 + cos(x[2])^2) #hide
nothing #hide
```


## Fill colors

The fill color of each interval/block is determined from a color function that can be specified with the `fill_color_function` keyword. To illustrate the principle, consider the default color function:

```julia
function default_color_function(current_weight,grid_weights)
	# Get the weight range.
	min_w, max_w  = extrema(grid_weights)
	if min_w == max_w
		opacity = 1
	else
		# Calculate the proportion of the current_weight.
		opacity = (current_weight - min_w)/(max_w - min_w)
	end
	return (opacity,"Midnight Blue")
end
```
The color function will be applied internally to every interval/block and must accept two arguments: `(val,Arr)`, where `val` will be the weight of the current interval/block and where `Arr` will be the vector of all wights in the grid. The color function must return two arguments, an opacity (number between `0` and `1`) and a color [compatible with `Plots.jl`](https://docs.juliaplots.org/latest/colors/).

As example, we can implement the color gradient `:thermal` form [`ColorsSchemes.jl`](https://docs.juliaplots.org/latest/generated/colorschemes/):
```@example 3
using ColorSchemes

thermal = cgrad(:thermal)

function thermal_function(current_weight,grid_weights)
	min_w, max_w  = extrema(grid_weights)
	weight_proportion = (current_weight - min_w)/(max_w-min_w)
	return (1,thermal[weight_proportion])
end
nothing #hide
```
To apply the new color function, we set `fill_color_function = thermal_function` for the plotting:
```@example 3
plot(two_dim_grid, fill_color_function = thermal_function)
```
At the moment, there is no way to add automatically generated colorbars to the plot. As workaround, the colorbars can be created manually, e.g. as explained in [Colorbars](@ref Colorbars)


The color function can also be used for a `OneDimGrid`:

```@example 3
plot(one_dim_grid, fill_color_function = thermal_function)
```
Since the bar height for `OneDimGrid`-plots already depicts the weight for each interval, a single fill color can be sufficient: 

```@example 3
plot(one_dim_grid, fill_color_function = (w,W) -> (1,"Midnight Blue"))
```

## Line colors

The color of the lines that separate the intervals/blocks can be changed with the `line_color_function` keyword. It works in the same way as `fill_color_function`:


```@example 3
plot(two_dim_grid, line_color_function = (w,W) ->  (1,"dark red"))
```
```@example 3
plot(one_dim_grid, line_color_function = (w,W) ->  (1,"dark red"))
```

It is possible to pass the same function to both `line_color_function` and `fill_color_function`. This allows to hide the lines that separate the intervals/blocks. 

```@example 3
plot(one_dim_grid, line_color_function = (w,W) -> (1,"Midnight Blue"), 
	fill_color_function = (w,W) -> (1,"Midnight Blue"))
```

Since the intervals/blocks are plotted one after another, interval/block-specific line colors can lead to visual artifacts. This effect can be exaggerated with increased line widths and the `thermal_function` that was defined in [Fill colors](@ref Fill-colors):
```@example 3
plot(two_dim_grid,linewidth = 6, line_color_function = thermal_function, 
	fill_color_function = thermal_function)
```

Reducing the line width, on the other hand, can fix the visual artifacts
```@example 3
plot(two_dim_grid, linewidth = 0.5, line_color_function = thermal_function, 
	fill_color_function = thermal_function)
```

## `OneDimGrid` bar height

The default plotting behavior for `OneDimGrid`-plots and `Grid`-plots differs, since one-dimensional grids can use the free `y`-axis to depict the weights of intervals. This behavior can be changed with the `height_function` that determines the bar-height, based on the weight of the corresponding interval. The default function is `x->x`, which produces bar heights equal to the respective interval weights.

To obtain `OneDimGrid`-plots that behave like `Grid`-plots, a constant height value needs to be set:
```@example 3
plot(one_dim_grid, height_function = x->1)
```

The `height_function` allows to separate the bar heights from the actual gird weights. For example, the absolute value can be plotted, but the true weight value can be used for the fill colors (using the `thermal_function` defined in [Fill colors](@ref Fill-colors)):

```@example 3
plot(one_dim_grid, height_function = x->abs(x), fill_color_function = thermal_function)
```

## `OneDimGrid` along the `y`-axis

A `OneDimGrid` can be plotted along the `y`-axis by setting `vertical=true`:
```@example 3
plot(one_dim_grid, vertical =true)
```

## Colorbars

Currently, there is no way to create automatic colorbars. As workaround, a colorbar can be created manually with a `OneDimGrid`-plot. For the example, we use the 2-dim example grid `two_dim_grid` and the `thermal_function` that was defined in [Fill colors](@ref Fill-colors).

First, we extract the weight range from `two_dim_grid`.

```@example 3
weight_range = extrema(export_weights(two_dim_grid))
```

Then, we create a new 1-dim grid `color_grid` that has `weight_range` as domain, and set up 100 intervals to get a continuous color bar:

```@example 3
# 101 discretization points -> 100 intervals 
color_grid = create_grid(LinRange(weight_range...,101))
nothing #hide
``` 

Next, we import 100 increasing, linearly spaced wights (e.g. `LinRange(0,1,100)`):

```@example 3
import_weights!(color_grid, LinRange(0,1,100))
nothing #hide
```

To plot the colorbar, we use the following options

* `thermal_function` for `line_color_function` and `fill_color_function`
* `height_function = x-> 1` to obtain a bar
* `yaxis=false` to disable the `y`-axis.

```@example 3
plot(color_grid, fill_color_function = thermal_function, 
	line_color_function = thermal_function, 
	height_function = x-> 1, yaxis = false)
```

In this form, the colorbar is not very useful.  To plot the colorbar next to the `two_dim_grid` plot, we can use subplots and layouts:

```@example 3
p1 = plot(two_dim_grid, fill_color_function = thermal_function)
p2 = plot(color_grid, fill_color_function = thermal_function, 
	line_color_function = thermal_function, 
	height_function = x-> 1, size = (600,50), yaxis = false)
plot(p1,p2, layout = @layout [a{0.9h}; b])
```

In the same way, a vertical colorbar can be created (using [`Measures.jl`](https://github.com/JuliaGraphics/Measures.jl) to adjust the margins):

```@example 3
using Measures
p1 = plot(two_dim_grid, fill_color_function = thermal_function)
p2 = plot(color_grid, fill_color_function = thermal_function, 
	line_color_function = thermal_function, 
	height_function = x-> 1, vertical = true,  
	xaxis = false, left_margin=5mm)
plot(p1,p2, layout = @layout [a{0.9w} b])
```