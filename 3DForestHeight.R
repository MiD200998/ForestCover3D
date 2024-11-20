# Load necessary libraries
library(terra)
library(sf)
library(geodata)
library(rayshader)

# Step 1: Download and load the raster file for forest canopy height
raster_url <- "https://libdrive.ethz.ch/index.php/s/cO8or7iOe5dT2Rt/download?path=%2F3deg_cogs&files=ETH_GlobalCanopyHeight_10m_2020_N39W009_Map.tif"
download.file(raster_url, destfile = "canopy_height.tif", mode = "wb")
forest_raster <- rast("canopy_height.tif")

# Step 2: Load the Portugal boundary as a polygon
portugal_sf <- geodata::gadm("PRT", level = 1, path = tempdir()) |> 
  sf::st_as_sf() |> 
  sf::st_union()

# Step 3: Crop the raster to the Portugal boundary
forest_raster_cropped <- crop(forest_raster, vect(portugal_sf), snap = "in", mask = TRUE)

# Step 4: Set min and max values to avoid any rendering issues
forest_raster_cropped <- setMinMax(forest_raster_cropped)

# Step 5: Reduce the resolution (optional) to speed up processing
forest_raster_aggregated <- aggregate(forest_raster_cropped, fact = 10)

# Step 6: Convert the raster to a matrix for rayshader visualization
height_matrix <- as.matrix(forest_raster_aggregated, wide = TRUE)

# Check the summary and minmax to ensure height data is valid
print(forest_raster_cropped)
minmax(forest_raster_cropped)
summary(height_matrix)

# Step 7: Create a 3D plot with rayshader (adjusting zscale for height exaggeration)
height_matrix %>%
  height_shade() %>%  # Remove texture argument for default
  plot_3d(height_matrix, zscale = 20, windowsize = c(800, 800), 
          phi = 45, theta = 45, zoom = 0.75)

# Step 8: Save the 3D plot as an image
render_snapshot("forest_canopy_3d_visualization.png")
