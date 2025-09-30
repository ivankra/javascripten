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
        help=('Fetch GitHub metadata. Optionally, provide API token from '
              'GitHub Settings > Developer settings > Personal access tokens'),
    )
    parser.add_argument('-f', '--format', action='store_true', help="Reformat metadata in markdown files.")

    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    update_data(args)

def update_data(args):
    rows = []
    if os.path.exists('data.json'):
        with open('data.json', 'r') as fp:
            rows = json.load(fp)

    orig_row_by_engine = {}
    for row in rows:
        orig_row_by_engine[row['engine']] = row

    rows = []

    for filename in sorted(glob.glob('*.md')):
        if filename == 'README.md' or '_' in filename:
            continue

        if os.isatty(1):
            print(f'\033[1K\r{filename} ', end='', flush=True)

        engine = filename.replace('.md', '')

        row = orig_row_by_engine.get(engine, {})
        row['engine'] = engine

        process_markdown(row, filename=filename, args=args)
        process_github(row, args=args)

        # Variants metadata are only used as base template in process_dist/process_bench()
        # If there's no built binary / benchmark data for a variant, it will be ignored.
        variants_metadata = {}
        for variant_filename in sorted(glob.glob(f'{engine}_*.md')):
            variant = variant_filename[len(engine)+1:-3]
            variants_metadata[variant] = {
                'engine': engine,
                'variant': variant,
            }
            if os.isatty(1):
                print(f'\033[1K\r{variant_filename} ', end='', flush=True)
            process_markdown(variants_metadata[variant], filename=variant_filename, args=args)
            del variants_metadata[variant]['title']

        row['bench'] = {}
        process_dist(row, variants_metadata=variants_metadata)
        process_bench(row, variants_metadata=variants_metadata)

        bench = row.pop('bench')
        row = {k: row[k] for k in sorted(row.keys())}
        if bench:
            row['bench'] = [bench[k] for k in sorted(bench.keys())]

        rows.append(row)

    if os.isatty(1):
        print('\033[1K\rOK', flush=True)

    with open('data.json', 'w') as fp:
        json.dump(rows, fp, ensure_ascii=False, indent=2, sort_keys=False)

    with open('data.js', 'w') as fp:
        fp.write('kJavascriptZoo = ')
        json.dump(rows, fp, ensure_ascii=False, indent=2, sort_keys=False)

    lines = open('README.md').readlines()
    idx = lines.index('## List of JavaScript engines\n')
    lines = lines[:(idx + 1)]

    with open('README.md', 'w') as fp:
        fp.write(''.join(lines) + '\n')
        print_markdown_table(rows, fp=fp)

# Parse markdown file and populate/update fields in row dict for that engine
def process_markdown(row, filename, args):
    lines = [s.rstrip() for s in open(filename).readlines()]

    assert lines[0].startswith('# ') and lines[1] == ''
    if 'title' not in row:
        row['title'] = lines[0][1:].strip()

    metadata_map = {
        'URL': 'url',
        'Repository': 'repository',
        'GitHub': 'github',    # if github not the main repo
        'Sources': 'sources',  # if no official repository

        'LOC': 'loc',
        'Language': 'language',
        'License': 'license',
        'Note': 'note',
        'Org': 'org',
        'Standard': 'standard',
        'Type': 'type',
        'Years': 'years',

        'Tech': 'tech',
        'Parser': 'parser',
        'Runtime': 'runtime',
        'VM': 'vm',
        'GC': 'gc',
        'JIT': 'jit',
        'Regex': 'regex',
    }
    metadata_order = list(metadata_map.values())

    # Drop existing keys that are recomputed from .md
    for k in metadata_map.values():
        if k in row:
            del row[k]
        if k + '_note' in row:
            del row[k + '_note']

    for k in ['loc_command']:
        if k in row:
            del row[k]

    line_no = 2

    if re.match('^[A-Z]', lines[2]):
        while line_no < len(lines):
            assert not re.match(r'^\*', lines[line_no])
            if lines[line_no] == '':
                line_no += 1
                break
            line_no += 1

        row['summary'] = ' '.join(lines[2:line_no]).strip()

    metadata_start = line_no
    metadata_lines = []

    # Parse metadata items from .md
    while line_no < len(lines) and lines[line_no]:
        line = lines[line_no]
        line_no += 1

        m = re.match(r'^\* ([-A-Za-z ]+): +(.*)$', line)
        assert m, line
        assert m[1].strip() in metadata_map, line

        key = metadata_map[m[1].strip()]
        val = m[2].strip()

        if key in ['repository', 'github'] and '<img' in val:
            val = re.sub(' *<img .*', '', val).rstrip()

        row[key] = val

        metadata_lines.append((key, line))

    metadata_end = line_no
    if args.format:
        # Sort metadata in metadata_map's order
        metadata_lines = [(metadata_order.index(k), v) for (k, v) in metadata_lines]
        metadata_lines = [v for (k, v) in sorted(metadata_lines)]

        # Also update shields
        for i in range(len(metadata_lines)):
            line = metadata_lines[i]
            shields = ''
            m = re.match(r'^\* (GitHub|Repository): *(https://github.com/[^/]+/[^/ ]+?(.git))', line)
            if m:
                shields = get_shields_for_repo(m[2], short=True)
            if shields:
                line = re.sub(' *<img .*', '', line) + ' ' + shields
                metadata_lines[i] = line

        reordered = lines[:metadata_start] + metadata_lines + lines[metadata_end:]
        with open(filename, 'w') as fp:
            fp.write('\n'.join(reordered).rstrip() + '\n')

    # Split up some "text (note)" keys
    for key in list(row.keys()):
        val = row[key]
        if key in ['summary', 'sources', 'tech'] or type(val) != str or '(' not in val:
            continue

        if key in ['loc', 'license', 'language', 'repository', 'github', 'parser', 'runtime']:
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
        elif key not in ['standard', 'type', 'jit', 'vm']:
            print(f'Unprocessed note in {key}: {val}')

    # license_abbr
    if row.get('license'):
        s = row['license']
        s = re.sub('BSD-([0-9])-Clause', r'BSD-\1', s)
        s = re.sub('-([0-9.]+)-only', r'-\1', s)
        s = re.sub('-([0-9.]+)-or-later', r'-\1+', s)
        s = re.sub(' *( OR| AND|,) *', '/', s)
        s = re.sub(' WITH[^,/]*', '', s)
        #s = re.sub('Apache[-0-9.+]', 'Apache', s)
        s = re.sub('Apache[-0-9.+]*/LGPL[-0-9.+]*', 'Apache/LGPL', s)
        s = re.sub('Apache[-0-9.+]*/MIT', 'Apache/MIT', s)
        s = re.sub('MPL[-0-9.+]*/GPL[-0-9.+]*/LGPL[-0-9.+]*', 'MPL/GPL/LGPL', s)
        s = re.sub('Artistic[-0-9.+A-Za-z]*/GPL[-0-9.+]+', 'Artistic/GPL', s)
        row['license_abbr'] = s

    # Integer keys
    for key in ['loc']:
        if key in row:
            row[key] = int(row[key])

# Populate fields with github data
def process_github(row, args):
    gh_repo_url = row.get('github', row.get('repository', row.get('sources')))
    if not gh_repo_url:
        return

    m = re.match('https?://github.com/([^/]+)/([^/]+?)(.git)?$', gh_repo_url)
    if not m:
        return

    owner = m[1]
    repo = m[2]

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

# Populate row.bench from dist/arch/engine-variant.json
def process_dist(row, variants_metadata):
    engine = row['engine']

    for arch in ARCH_LIST:
        for filename in glob.glob(f'dist/{arch}/{engine}.json') + \
                        glob.glob(f'dist/{arch}/{engine}_*.json'):
            with open(filename, 'r') as fp:
                dist_json = json.load(fp)

            assert dist_json.pop('engine') == engine, f'Expected {filename} to have engine: {engine}'

            assert dist_json.get('arch', arch) == arch
            dist_json['arch'] = arch

            variant = dist_json.get('variant', '')
            assert filename.endswith(variant + '.json')

            row['bench'][f'{arch}/{engine}/{variant}'] = merge_jsons(
                variants_metadata.get(variant), dist_json)

# Populate row.bench from benchmarking data in bench/data.py
def process_bench(row, variants_metadata):
    engine = row['engine']

    for bench_json in kBenchData:
        if bench_json['engine'] != engine: continue

        head_cols = ['arch', 'variant', 'binary_size', 'revision', 'revision_date', 'version']
        bench_json = {k: bench_json[k] for k in head_cols + sorted(bench_json.keys()) if k in bench_json}

        assert bench_json.pop('engine') == engine
        arch = bench_json['arch']
        variant = bench_json.get('variant', '')

        for col in sorted(bench_json.keys()):
            if type(bench_json[col]) is not dict: continue
            if 'scores' not in bench_json[col]: continue
            scores = bench_json[col]['scores']
            scores = list(sorted(scores))
            assert len(scores) >= 1
            bench_json[col] = scores[len(scores) // 2]
            bench_json[col + '_note'] = summarize_scores(scores)

        if variant == 'jitless':
            bench_json['jit'] = ''

        row['bench'][f'{arch}/{engine}/{variant}'] = merge_jsons(
            variants_metadata.get(variant), bench_json)

def merge_jsons(*jsons):
    res = {}
    for json in jsons:
        if json is not None:
            res.update(json)
    return res

def summarize_scores(scores):
    n = len(scores)
    median = list(sorted(scores))[n // 2]
    mean = sum(scores) / n
    if n == 1:
        return f'N={n} median={median} mean={mean:.0f} max={max(scores)}'
    sd = (sum([(x - mean)**2 for x in scores]) / (n - 1.0)) ** 0.5
    sem = sd / (n ** 0.5)
    return f'N={n} median={median} mean={mean:.2f}±{sem:.2f} max={max(scores)}'

def get_shields_for_repo(repo_link, short=True):
    m = re.match('https?://github.com/([^/]+)/([^/]+?)(.git)?$', repo_link)
    if not m:
        return ''
    if short:
        return (
            f'<img src="https://img.shields.io/github/stars/{m[1]}/{m[2]}?label=&style=flat-square" alt="Stars">' +
            f'<img src="https://img.shields.io/github/last-commit/{m[1]}/{m[2]}?label=&style=flat-square" alt="Last commit">'
        )
    else:
        return (
            f'<img src="https://img.shields.io/github/stars/{m[1]}/{m[2]}?label=stars&style=flat-square" alt="GitHub"><br>' +
            f'<img src="https://img.shields.io/github/last-commit/{m[1]}/{m[2]}?label=&style=flat-square">'
        )

def get_domain(url):
    m = re.match('^https?://?([^/]+).*', url)
    if m:
        host = m[1]
        if host.count('.') > 1:
            return '.'.join(host.split('.')[-2:])
        return host

def print_markdown_table(rows, fp):
    pinned = 'v8 spidermonkey jsc'.split()

    for row in rows:
        s = row.get('language', '')
        s = re.sub(', .*', '', s)
        row['language_pad'] = '%-10s' % s

        if row['engine'] in pinned:
            row['sort_key'] = 'A%02d' % pinned.index(row['engine'])
        else:
            row['sort_key'] = ' '.join([
                s.replace('TypeScript', 'JavaScriptT').replace('C++', 'C'),
                '%06d' % (999999 - row.get('github_stars', 0)),
                row['engine'].lower()
            ])

        # link to .md
        row['title_pad'] = '%-32s' % f'[{row["title"]}]({row["engine"]}.md)'

        repo_link = row.get('github', row.get('repository', ''))
        repo_text = ''
        if not repo_link and row.get('url', '').startswith('http'):
            repo_link = row['url']
        if repo_link:
            repo_text = get_domain(repo_link) or 'link'
        m = re.match('https?://github.com/([^/]+)/([^/]+?)(.git)?$', repo_link)
        if m:
            repo_text = f'{m[1]}/{m[2]}'
        if re.match(r'https?://github.com/.*\.git$', repo_link):
            repo_link = repo_link[:-4]
        if repo_link:
            row['repository_link'] = f'[{repo_text}]({repo_link})'
            shields = get_shields_for_repo(repo_link, short=False).strip()
            if shields:
                row['repository_link'] = f'[{shields}]({repo_link})'

    rows.sort(key=lambda row: row['sort_key'])

    cols = {
        'title_pad': 'Engine',
        'language_pad': 'Language',
        'summary': 'Description',
        'license_abbr': 'License',
        'repository_link': 'GitHub/URL',
    }
    print('<!-- Do not edit: autogenerated by data-gen.py -->', file=fp)
    print('| %s |' % (' | '.join(cols.values())), file=fp)
    print('|---' * len(cols) + '|', file=fp)
    for row in rows:
        values = [str(row.get(c, '')) for c in cols.keys()]
        print('| %s |' % (' | '.join(values)), file=fp)

if __name__ == '__main__':
    main()
