import 'dotenv/config';
import { startSimpleRun, subscribeSimpleRun, getSimpleRunState } from '../src/simplePipeline.js';

const nl = `Design a handheld environmental monitor that measures PM2.5, CO2, temperature, and humidity, runs 8 hours on a rechargeable battery, and syncs data via Wi-Fi or Bluetooth.`;

const { runId } = startSimpleRun(nl, 3);
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

const deadline = Date.now() + 180000; // 3 minutes
const timer = setInterval(() => {
  const s = getSimpleRunState(runId);
  if (!s) return;
  if (s.status === 'done' || s.status === 'error' || Date.now() > deadline) {
    clearInterval(timer);
    unsubscribe();
    console.log('\nFinal status:', s.status);
    console.log('Requirements SysML path:', s.outputs.requirementsPath);
    console.log('Concepts:', s.outputs.concepts?.map((c) => c.name));
    console.log('Concept SysML files:', s.outputs.conceptSysml?.map((c) => ({ idx: c.index + 1, path: c.sysmlPath, status: c.status })));
    if (Date.now() > deadline) {
      console.log('Timed out waiting for completion.');
    }
    process.exit(0);
  }
}, 4000);
