#!/usr/bin/env python3
import pya

# Off-screen LayoutView rendering for KLayout
view = pya.LayoutView()
gds_file = "/home/roohith/spi_workspace/spi_openroad/results/spi_top.gds"
lyp_file = "/home/roohith/OpenROAD-flow-scripts/flow/platforms/nangate45/FreePDK45.lyp"
out_img  = "/home/roohith/spi_workspace/docs/images/spi_layout_gds.png"

print(f"Loading GDS layout: {gds_file}...")
view.load_layout(gds_file, 0)

print(f"Applying Nangate45/FreePDK45 layer styles: {lyp_file}...")
view.load_layer_props(lyp_file)

view.max_hier()
view.zoom_fit()

print(f"Rendering high-resolution 1920x1920 image to {out_img}...")
view.save_image(out_img, 1920, 1920)
print("[SUCCESS] Layout render complete!")
