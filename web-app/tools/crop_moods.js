// Simple script to split web-app/public/moods-inline.png into 5 equal-width images
// Usage: node tools/crop_moods.js
const path = require('path')
const Jimp = require('jimp')

async function run() {
  const src = path.join(__dirname, '..', 'public', 'moods-inline.png')
  const outDir = path.join(__dirname, '..', 'public')
  const img = await Jimp.read(src)
  const w = img.getWidth()
  const h = img.getHeight()
  const per = Math.floor(w / 5)
  for (let i = 0; i < 5; i++) {
    const x = i * per
    const cropW = i === 4 ? (w - x) : per
    const clone = img.clone()
    clone.crop(x, 0, cropW, h)
    const out = path.join(outDir, `mood-${i + 1}.png`)
    await clone.writeAsync(out)
    console.log('Wrote', out)
  }
}

run().catch((e) => { console.error(e); process.exit(1) })
