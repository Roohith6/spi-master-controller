import glob

for p in glob.glob('/home/roohith/OpenROAD-flow-scripts/flow/scripts/*.tcl'):
    with open(p, 'r') as f:
        content = f.read()
    if 'utl::set_metrics_stage' in content:
        lines = content.split('\n')
        new_lines = []
        for l in lines:
            if l.strip().startswith('utl::set_metrics_stage'):
                new_lines.append('catch {' + l.strip() + '}')
            else:
                new_lines.append(l)
        with open(p, 'w') as f:
            f.write('\n'.join(new_lines))
        print('Patched:', p)
