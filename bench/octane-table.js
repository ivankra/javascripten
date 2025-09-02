#!/usr/bin/env node

const fs = require('fs');

const raw_data = {
  "x64": {
    'metadata': JSON.parse(fs.readFileSync('metadata-x64.json')),
    'runs': eval('(' + fs.readFileSync('octane-x64.js') + ')'),
  },

  'arm64': {
    'metadata': JSON.parse(fs.readFileSync('metadata-arm64.json')),
    'runs': eval('(' + fs.readFileSync('octane-arm64.js') + ')'),
  },
};

function drop_empty_keys(obj) {
  if (!obj) return obj;
  const kv = Object.entries(obj).filter(([k, v]) => (v !== '' && v !== null));
  return Object.fromEntries(kv);
}

function aggregate_scores(arr, fn) {
  if (!Array.isArray(arr) || arr.length === 0) {
    return null;
  }
  arr = arr.filter(x => typeof x === 'number');
  if (fn == 'max') {
    return Math.max(...arr);
  } else if (fn == 'gm') {
    return Math.exp(arr.map(x => Math.log(x)).reduce((x, y) => x + y) / arr.length)|0;
  } else if (fn == 'mean') {
    return (arr.reduce((x, y) => x+y, 0) / arr.length);
  } else if (fn == 'iqmean') {
    const k = arr.length >> 2;
    arr = arr.slice(k, arr.length - k);
    return (arr.reduce((x, y) => x+y, 0) / arr.length);
  } else if (fn == 'median') {
    return arr.toSorted()[arr.length >> 1];
  } else if (fn == 'sd') {
    const m = (arr.reduce((x, y) => x+y, 0) / arr.length);
    const q = (arr.reduce((x, y) => x + (y - m)**2, 0) / arr.length);
    return q**0.5;
  }
}

function aggregate_run(run, fn='max') {
  if (!run) return {};
  const kv =
    Object.entries(run)
    .filter(([k, v]) => !k.includes('Latency'))
    .map(([k, v]) => {
      return [k, Array.isArray(v?.scores) ? aggregate_scores(v.scores, fn) : v];
    });
  return Object.fromEntries(kv);
}

function process_raw(raw) {
  const engines = new Set([...Object.keys(raw.metadata), ...Object.keys(raw.runs)]);
  const rows = [];
  for (const engine of engines) {
    const run = aggregate_run(raw.runs[engine]);
    const row = drop_empty_keys({
      ...{
        'engine': engine,
        'total': run ? aggregate_scores(Object.values(run), 'gm') : null,
      },
      // Merge metadata from parent, e.g. v8 into v8-jitless
      // Except for description column.
      ...(drop_empty_keys(raw.metadata[engine.replace(/-.*/, '')]) ?? {}),
      'description': null,
      'tech': null,
      ...(drop_empty_keys(raw.metadata[engine]) ?? {}),
      ...run,
    });
    rows.push(row);
  }
  const sorted = rows.toSorted((x, y) => (y.total ?? 0) - (x.total ?? 0));
  return sorted;
}

console.log('arm64');
console.table(process_raw(raw_data['arm64']));
console.log('x64');
console.table(process_raw(raw_data['x64']));
