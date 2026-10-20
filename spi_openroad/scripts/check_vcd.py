with open('/home/roohith/spi_workspace/verif/sim/spi_tb.vcd') as f:
    lines = [line.strip() for line in f]

symbols = {}
for line in lines:
    if line.startswith('$var'):
        parts = line.split()
        name = parts[4]
        sym = parts[3]
        if any(x in name for x in ['sclk', 'mosi', 'tip', 'go', 'cnt', 'ss']):
            symbols[sym] = name

print("Tracked symbols:", symbols)

# Now scan timestamps and value changes
current_time = 0
changes = []
for line in lines:
    if line.startswith('#'):
        current_time = int(line[1:])
    elif not line.startswith('$'):
        for sym, name in symbols.items():
            if line.endswith(sym):
                val = line[:-len(sym)]
                changes.append((current_time, name, val))

print(f"Total value changes recorded for tracked signals: {len(changes)}")
for c in changes[:40]:
    print(f"Time {c[0]} ps ({c[0]/1000:.1f} ns): {c[1]} = {c[2]}")
