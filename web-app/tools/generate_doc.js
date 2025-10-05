#!/usr/bin/env node
// Simple generator to create a React docs page and a static HTML fallback
// Usage: node tools/generate_doc.js --slug my-doc --title "My Doc" --content "<p>Body</p>"

const fs = require('fs')
const path = require('path')

function usage(){
  console.log('Usage: node tools/generate_doc.js --slug <slug> --title "Title" --content "<p>HTML</p>"')
}

const argv = require('minimist')(process.argv.slice(2))
const slug = argv.slug
const title = argv.title || 'Doc'
const content = argv.content || '<p>Update content</p>'

if(!slug){ usage(); process.exit(1)}

const pagesDir = path.join(__dirname, '..', 'src', 'pages')
const publicDir = path.join(__dirname, '..', 'public', 'docs')

if(!fs.existsSync(pagesDir)) fs.mkdirSync(pagesDir, { recursive: true })
if(!fs.existsSync(publicDir)) fs.mkdirSync(publicDir, { recursive: true })

const componentPath = path.join(pagesDir, `${slug}.tsx`)
const htmlPath = path.join(publicDir, `${slug}.html`)

const comp = `import React from 'react'

export default function ${slug.replace(/-([a-z])/g, (m,g)=>g.toUpperCase())}(){
  return (
    <div style={{ padding: 28 }}>
      <h1>${title}</h1>
      <div>${content}</div>
      <p style={{ marginTop: 18 }}><a href="/">← Back to app</a></p>
    </div>
  )
}
`

const html = `<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>${title}</title>
</head>
<body>
<div style="padding:28px">
<h1>${title}</h1>
${content}
<p style="margin-top:18px"><a href="/">← Back to app</a></p>
</div>
</body>
</html>`

fs.writeFileSync(componentPath, comp)
fs.writeFileSync(htmlPath, html)

console.log('Created', componentPath, htmlPath)
