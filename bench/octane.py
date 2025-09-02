#!/usr/bin/env python3
# Runner for octane benchmarks tests.
# Takes js binary + flags, runs repeatedly on each single test.
import os
import sys
import subprocess
import time
import re
import json
import glob
from pathlib import Path

# Run 'make' to generate
OCTANE_TESTS = [
   'richards.js',
   'deltablue.js',
   'crypto.js',
   'raytrace.js',
   'earley-boyer.js',
   'regexp.js',
   'splay.js',
   'navier-stokes.js',
   'pdfjs.js',
   'mandreel.js',
   'gbemu.js',
   'code-load.js',
   'box2d.js',
   'zlib.js',
   'typescript.js',
]

def main():
    args = sys.argv[1:]

    reps = 20
    if len(args) >= 2 and args[0] == '-r':
        reps = int(args[1])
        args = args[2:]

    test_files = []
    while len(args) > 1 and args[-1].endswith('.js'):
        test_files = [args.pop()] + test_files

    if not args:
        print('Usage: ./bench.py [-r reps] binary [flags] [test.js ...]', file=sys.stderr)
        sys.exit(1)

    if not test_files:
        script_dir = Path(__file__).parent
        test_files = [os.path.join(script_dir, s) for s in OCTANE_TESTS]
        if not os.path.exists(test_files[0]):
            cmd = f'cd "{script_dir}" && make'
            print(f'Running: {cmd}')
            sys.stdout.flush()
            os.system(cmd)

    test_files = [os.path.realpath(os.path.abspath(s)) for s in test_files]

    results = {}

    for test_file in test_files:
        test_file_path = Path(test_file)
        if not test_file_path.exists():
            print_warning(f'{test_file} not found')
            continue

        scores_by_test = {}
        wall_times = []

        cmd = args + [test_file]
        print(f'Running: {' '.join(cmd)}')

        cmd_str = ' '.join([f"'{s}'" for s in cmd])
        tee_cmd = f'{cmd_str} 2>&1 | tee /dev/stderr'

        for i in range(reps):
            sys.stdout.flush()
            try:
                timeout = 600
                start_time = time.time()
                result = subprocess.run(tee_cmd, shell=True, stdin=None, stdout=subprocess.PIPE,
                                        text=True, timeout=timeout)
                wall_time = time.time() - start_time

                if result.returncode != 0:
                    raise Exception(f'Exit code {result.returncode}')

                test_scores = extract_scores(result.stdout)
                if not test_scores:
                    raise Exception('No scores found in output')

                for test_name, score in test_scores:
                    if test_name not in scores_by_test:
                        scores_by_test[test_name] = []
                    scores_by_test[test_name].append(score)

                wall_times.append(wall_time)

            except Exception as e:
                print_warning(f'{test_file} failed: {e}')
                break

        if len(wall_times) == 0:
            continue

        avg_wall_time = sum(wall_times) / len(wall_times)

        for test_name, scores in scores_by_test.items():
            assert len(wall_times) == len(scores)
            res = {
                'score_iqmean': int(interquartile_mean(scores)),
                'time_avg': round(avg_wall_time, 2),
                'scores': list(sorted(map(int, scores))),
            }
            print(f"'{test_name}': {res}")
            sys.stdout.flush()
            results[test_name] = res

    comment = ''
    if len(args) > 1:
        comment = '  // ' + ' '.join(args)
    print("Full results:\n  '%s': {%s" % (os.path.basename(args[0]), comment))
    for test_name, res in results.items():
        print(f"    '{test_name}': {str(res)},")
    print('  },')

def print_warning(msg):
    print(f'\033[31m{msg}\033[0m' if os.isatty(0) else msg)

def extract_scores(output):
    scores = []
    matches = re.findall(r'([A-Zz][a-zA-Z0-9]+): (\d+)', output)
    for name, score in matches:
        if name == 'LEAK': continue
        scores.append((name, float(score)))
    return scores

def interquartile_mean(values):
    values = sorted(values)
    n = len(values)
    k = n // 4
    assert n == 0 or n-2*k >= 1
    values = values[k:(n-k)]
    return sum(values) / len(values) if len(values) > 0 else None

if __name__ == '__main__':
    main()
