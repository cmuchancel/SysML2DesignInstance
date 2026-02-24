import 'dotenv/config';
import fs from 'fs';
import { startSimpleRun, subscribeSimpleRun, getSimpleRunState } from '../src/simplePipeline.js';

const filePath = process.argv[2];
if (!filePath) {
  console.error('usage: npx tsx scripts/run_from_file.ts <nl_prompt_file> [conceptCount]');
  process.exit(1);
}
const conceptCount = Number(process.argv[3] || 3);
const nl = fs.readFileSync(filePath, 'utf-8');
const { runId } = startSimpleRun(nl, conceptCount);
console.log('runId:', runId);

const unsubscribe = subscribeSimpleRun(runId, (s) => {
  console.log('progress:', JSON.stringify({
    status: s.status,
    req: s.stages.requirements.status,
    concepts: s.stages.concepts.status,
    c1: s.stages.conceptsExpansion[0]?.status,
    c2: s.stages.conceptsExpansion[1]?.status,
    c3: s.stages.conceptsExpansion[2]?.status,
  }));
});

const deadline = Date.now() + 8 * 60 * 1000; // 8 minutes
const timer = setInterval(() => {
  const s = getSimpleRunState(runId);
  if (!s) return;
  const done = s.status === 'done' || s.status === 'error';
  const timedOut = Date.now() > deadline;
  if (done || timedOut) {
    clearInterval(timer);
    unsubscribe();
    console.log('\nFinal status:', s.status, timedOut ? '(timeout)' : '');
    console.log('Requirements:', s.outputs.requirementsPath);
    console.log('Concepts:', s.outputs.concepts?.map((c) => c.name));
    console.log('Concept SysML files:', s.outputs.conceptSysml?.map((c) => ({ idx: c.index + 1, path: c.sysmlPath, status: c.status })));
    if (timedOut) process.exit(124);
    process.exit(s.status === 'done' ? 0 : 1);
  }
}, 5000);
