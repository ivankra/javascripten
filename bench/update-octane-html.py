#!/usr/bin/env python3

import os, os.path

blocks = {}
lines = []
ref = None

for line in open('octane.html'):
    if line.startswith('// BEGIN '):
        assert ref is None
        ref = line[len('// BEGIN '):].strip()
        assert ref not in blocks
        blocks[ref] = []
        lines.append(line)
        lines.append({'ref': ref})
    elif line.startswith('// END '):
        assert ref == line[len('// END '):].strip()
        ref = None
        lines.append(line)
    elif ref:
        blocks[ref].append(line)
    else:
        lines.append(line)

changed = False
for ref in blocks.keys():
    if not os.path.exists(ref):
        print(f"{ref}: doesn't exist, skipping")
        #print(f'Creating {ref} from contents in octane.html')
        #with open(ref, 'w') as fp:
        #    fp.writelines(blocks[ref])
    else:
        contents = open(ref).readlines()
        if contents == blocks[ref]:
            print(f'{ref}: unchanged')
        else:
            print(f'{ref}: {len(blocks[ref])} -> {len(contents)} lines')
            blocks[ref] = contents
            changed = True

if changed:
    with open('octane.html.tmp', 'w') as fp:
        for line in lines:
            if type(line) is dict:
                for ref_line in blocks[line['ref']]:
                    fp.write(ref_line)
            else:
                fp.write(line)
    os.rename('octane.html.tmp', 'octane.html')
