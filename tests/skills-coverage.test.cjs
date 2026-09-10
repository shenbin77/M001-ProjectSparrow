'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {characters} = require('../data/characters.json');

const skillsSrc = fs.readFileSync(path.join(__dirname, '..', 'game', 'skills.gd'), 'utf8');
const ids = [...skillsSrc.matchAll(/"id":\s*"([^"]+)"/g)].map(m => m[1]);
const effects = [...skillsSrc.matchAll(/"effect":\s*"([^"]+)"/g)].map(m => m[1]);
const costs = [...skillsSrc.matchAll(/"cost":\s*(\d+)/g)].map(m => Number(m[1]));
const levels = [...skillsSrc.matchAll(/"unlock_level":\s*(\d+)/g)].map(m => Number(m[1]));

const OLD_IDS = ["power_training", "speed_drill", "endurance_run", "scholarship_fund", "campus_job", "internship", "study_group", "invest_club"];
const NEW_IDS = ["shanten_drill", "discard_discipline", "defense_reading", "sponsor_negotiation", "media_appearance"];

test('skills.gd keeps all eight original ids in their original order', () => {
  assert.deepEqual(ids.slice(0, 8), OLD_IDS);
});

test('skills.gd appends the five new ids after the originals', () => {
  assert.deepEqual(ids.slice(8), NEW_IDS);
  assert.equal(ids.length, 13);
  assert.equal(new Set(ids).size, 13);
});

test('skills.gd only uses the two existing effect types with costs and levels in range', () => {
  assert.equal(effects.length, ids.length);
  assert.ok(effects.every(e => e === 'training_xp' || e === 'economy'), 'effect whitelist');
  assert.ok(costs.every(c => c >= 50 && c <= 180), 'cost range');
  assert.ok(levels.every(l => l >= 1 && l <= 6), 'unlock level range');
});

test('every character carries a whitelisted play_style', () => {
  assert.equal(characters.length, 8);
  for (const c of characters) assert.ok(['offensive', 'balanced', 'defensive'].includes(c.play_style), c.id);
});
