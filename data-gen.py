#!/usr/bin/env python3

import argparse
import glob
import json
import os
import os.path
import re
import requests
import sys
import time

from bench.data import kBenchData

ARCH_LIST = ['arm64', 'x64']

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--github',
        nargs='?',
        metavar='TOKEN',
        const='',
        help='Fetch GitHub metadata. Optionally provide a token for higher rate limits (GitHub Settings > Developer settings > Personal access tokens)',
    )
    parser.add_argument(
        '--dist',
        action='store_true',
        help="Build helper, generate .json for current build"
    )

    args = parser.parse_args()

    if args.dist:
        return

    update_data(args)

def update_data(args):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    rows = []
    if os.path.exists('data.json'):
        print('Reading existing data.json')
        with open('data.json', 'r') as fp:
            rows = json.load(fp)

    orig_row_by_engine = {}
    for row in rows:
        orig_row_by_engine[row['engine']] = row

    for arch in ARCH_LIST:
        migrate_dist(arch)

    rows = []

    for filename in sorted(glob.glob('*.md')):
        if filename == 'README.md':
            continue

        print(f'\033[1K\r{filename} ', end='', flush=True)

        engine = filename.replace('.md', '')

        row = orig_row_by_engine.get(engine, {})
        row['engine'] = engine

        process_markdown(row, filename)
        process_github(row, args)

        row['bench'] = {}
        process_dist(row)
        process_bench(row)

        bench = row.pop('bench')
        row = {k: row[k] for k in sorted(row.keys())}
        if bench:
            row['bench'] = [bench[k] for k in sorted(bench.keys())]

        rows.append(row)

    with open('data.json', 'w') as fp:
        json.dump(rows, fp, ensure_ascii=False, indent=2, sort_keys=False)
    print('\033[1K\rWrote data.json', flush=True)

    with open('data.js', 'w') as fp:
        fp.write('kJavascriptZoo = ')
        json.dump(rows, fp, ensure_ascii=False, indent=2, sort_keys=False)
    print('Wrote data.js', flush=True)

# Parse markdown file and populate/update fields in row dict for that engine
def process_markdown(row, filename):
    lines = [s.rstrip() for s in open(filename).readlines()]

    assert lines[0].startswith('# ') and lines[1] == ''
    row['title'] = lines[0][1:].strip()

    line_no = 2

    if re.match('^[A-Z]', lines[2]):
        while line_no < len(lines):
            assert not re.match(r'^\*', lines[line_no])
            if lines[line_no] == '':
                line_no += 1
                break
            line_no += 1

        row['summary'] = ' '.join(lines[2:line_no]).strip()

    json_key_map = {
        'Summary': 'summary',
        'Repository': 'repository',
        'GitHub': 'github',    # if used to be hosted on github
        'Sources': 'sources',  # if no official repository
        'URL': 'url',
        'GC': 'gc',
        'LOC': 'loc',
        'Language': 'language',
        'License': 'license',
        'Tech': 'tech',
        'Note': 'note',
        'Org': 'org',
        'Regex': 'regex',
        'VM': 'vm',
        'Parser': 'parser',
        'Runtime': 'runtime',
        'Standard': 'standard',
        'Years': 'years',
    }

    # Drop existing keys that are recomputed from .md
    for k in json_key_map.values():
        if k in row:
            del row[k]
        if k + '_note' in row:
            del row[k + '_note']

    for k in ['loc_command']:
        if k in row:
            del row[k]

    # Parse metadata items from .md
    while line_no < len(lines) and lines[line_no]:
        line = lines[line_no]
        line_no += 1

        m = re.match(r'^\* ([-A-Za-z ]+): +(.*)$', line)
        assert m, line
        assert m[1].strip() in json_key_map, line

        key = json_key_map[m[1].strip()]
        val = m[2].strip()
        row[key] = val

    # Split up some "text (note)" keys
    for key in list(row.keys()):
        val = row[key]
        if key in ['summary', 'sources', 'tech'] or type(val) != str or '(' not in val:
            continue

        if key in ['loc', 'license', 'language', 'repository', 'github', 'parser', 'runtime', 'vm']:
            m = re.match(r'([^(]+) \(((?:)([^(]|`[^`]+`|\(http[^)]+\))+)\)$', val)
            assert m, (key, val)
            row[key + '_note'] = m[2]
            row[key] = m[1].strip()

            if key == 'loc':
                mm = re.match(r'^`(cloc [^`]+)`(.*)$', m[2])
                if mm:
                    row['loc_command'] = mm[1]
                    if mm[2] == '':
                        del row['loc_note']
        elif key not in ['standard']:
            print(f'Unprocessed note in {key}: {val}')

    for key in ['loc']:
        if key in row:
            row[key] = int(row[key])

# Populate fields with github data
def process_github(row, args):
    repo_url = row.get('github', row.get('repository', row.get('sources')))
    if not repo_url:
        return

    m = re.match('https?://github.com/([^/]+)/([^/]+)(.git)?$', repo_url)
    if not m:
        return

    owner = m[1]
    repo = m[2]
    if repo.endswith('.git'):
        repo = repo[:-4]

    api_url = f"https://api.github.com/repos/{owner}/{repo}"
    cache_filename = f'.cache/github/{row["engine"]}.json'

    if os.path.exists(cache_filename):
        with open(cache_filename) as fp:
            github_data = json.load(fp)
    elif args.github is not None:
        time.sleep(1)

        headers = {}
        if args.github != '':
            headers = {'Authorization': f'token {args.github}'}

        response = requests.get(api_url, headers=headers)
        if response.status_code != 200:
            print(f'{api_url}: {response.status_code}')
            return

        github_data = response.json()

        os.makedirs(f'.cache/github', exist_ok=True)
        with open(f'.cache/github/{row["engine"]}.json', 'w') as fp:
            json.dump(github_data, fp, ensure_ascii=False, indent=2, sort_keys=True)
    else:
        return

    row['github_stars'] = github_data['stargazers_count']
    row['github_forks'] = github_data['forks_count']

def migrate_dist(arch):
    if not os.path.exists(f'bench/metadata-{arch}.json'):
        return

    js = json.load(open(f'bench/metadata-{arch}.json'))
    for engine_var in js.keys():
        d = js[engine_var]
        d = {k: v for (k, v) in d.items() if k in ('binarySize', 'version', 'revision', 'revisionDate') and v}
        if len(d) == 0:
            continue
        d['arch'] = arch
        if 'binarySize' in d:
            d['binary_size'] = int(d.pop('binarySize'))
        if 'revisionDate' in d:
            d['revision_date'] = d.pop('revisionDate')

        for var in ['-jitless']:
            if engine_var.endswith(var):
                d['engine'] = engine_var[:len(engine_var)-len(var)]
                d['variant'] = var[1:]
                break
        else:
            d['engine'] = engine_var

        os.makedirs(f'dist/{arch}', exist_ok=True)
        with open(f'dist/{arch}/{engine_var}.json', 'w') as fp:
            json.dump(d, fp, ensure_ascii=False, indent=2, sort_keys=True)

# Populate row.bench from dist/arch/engine-variant.json
def process_dist(row):
    engine = row['engine']

    for arch in ARCH_LIST:
        for filename in glob.glob(f'dist/{arch}/{engine}.json') + \
                        glob.glob(f'dist/{arch}/{engine}-*.json'):
            with open(filename, 'r') as fp:
                dist_json = json.load(fp)

            if engine in ['quickjs'] and dist_json['engine'] != engine:
                continue  # skip quickjs/quickjs-ng, verify for all others
            assert dist_json.pop('engine') == engine, (filename, engine)

            assert dist_json.get('arch', arch) == arch
            dist_json['arch'] = arch

            variant = dist_json.get('variant', '')
            assert filename.endswith(variant + '.json')

            row['bench'][f'{arch}/{engine}/{variant}'] = dist_json

# Populate row.bench from benchmarking data in bench/data.py
def process_bench(out_row):
    engine = out_row['engine']

    for row in kBenchData:
        if row['engine'] != engine: continue

        head_cols = ['arch', 'variant', 'binary_size', 'revision', 'revision_date', 'version']
        row = {k: row[k] for k in head_cols + sorted(row.keys()) if k in row}

        assert row.pop('engine') == engine
        arch = row['arch']
        variant = row.get('variant', '')

        for col in sorted(row.keys()):
            if type(row[col]) is not dict: continue
            if 'scores' not in row[col]: continue
            scores = row[col]['scores']
            scores = list(sorted(scores))
            assert len(scores) >= 1
            row[col] = scores[len(scores) // 2]
            row[col + '_note'] = summarize_scores(scores)

        out_row['bench'][f'{arch}/{engine}/{variant}'] = row

def summarize_scores(scores):
    n = len(scores)
    median = list(sorted(scores))[n // 2]
    mean = sum(scores) / n
    if n == 1:
        return f'N={n} median={median} mean={mean:.0f} max={max(scores)}'
    sd = (sum([(x - mean)**2 for x in scores]) / (n - 1.0)) ** 0.5
    sem = sd / (n ** 0.5)
    return f'N={n} median={median} mean={mean:.2f}±{sem:.2f} max={max(scores)}'

if __name__ == '__main__':
    main()
