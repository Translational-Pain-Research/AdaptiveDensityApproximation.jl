using Documenter, AdaptiveDensityApproximation

makedocs(sitename="AdaptiveDensityApproximation.jl", pages = [
"AdaptiveDensityApproximation"=>"index.md" ,
"Plotting grids"=>["Plotting basics" => "plotting_basics.md", "Plotting options" => "plotting_keywords.md"],
"API"=>"api.md" ,
])
