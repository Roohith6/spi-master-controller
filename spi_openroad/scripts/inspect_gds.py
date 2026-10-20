import pya

layout = pya.Layout()
layout.read("/home/roohith/spi_workspace/spi_openroad/results/spi_top.gds")

top = layout.top_cell()
bbox = top.bbox()
dbu = layout.dbu

num_insts = sum(1 for _ in top.each_inst())

print(f"Top Cell Name:       {top.name}")
print(f"Database Unit (DBU): {dbu} um")
print(f"Bounding Box:        ({bbox.left * dbu:.2f}, {bbox.bottom * dbu:.2f}) to ({bbox.right * dbu:.2f}, {bbox.top * dbu:.2f}) um")
print(f"Die Dimensions:      {bbox.width() * dbu:.2f} um x {bbox.height() * dbu:.2f} um")
print(f"Total Die Area:      {(bbox.width() * dbu) * (bbox.height() * dbu):.2f} um^2")
print(f"Unique Cell Masters: {layout.cells()}")
print(f"Top-Level Instances: {num_insts}")

with open("/home/roohith/spi_workspace/spi_openroad/reports/gds_summary.rpt", "w") as f:
    f.write("=== GDSII PHYSICAL LAYOUT SUMMARY ===\n")
    f.write(f"Top Cell:            {top.name}\n")
    f.write(f"Die Dimensions:      {bbox.width() * dbu:.2f} um x {bbox.height() * dbu:.2f} um\n")
    f.write(f"Total Die Area:      {(bbox.width() * dbu) * (bbox.height() * dbu):.2f} um^2\n")
    f.write(f"Unique Cell Masters: {layout.cells()}\n")
    f.write(f"Total Placed Insts:  {num_insts}\n")
