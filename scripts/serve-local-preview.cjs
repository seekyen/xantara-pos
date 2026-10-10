const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');

const root = path.resolve(__dirname, '../build/web-device-preview');
const mime = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.css': 'text/css', '.png': 'image/png', '.svg': 'image/svg+xml', '.ico': 'image/x-icon', '.woff2': 'font/woff2', '.ttf': 'font/ttf' };
const cache = new Map();
http.createServer((req, res) => {
  // Keep browser API traffic on the preview origin, including sync headers.
  if (req.url.startsWith('/api/') || req.url.startsWith('/media/')) {
    const upstream = http.request({
      hostname: '127.0.0.1', port: 8000, path: req.url, method: req.method,
      headers: { ...req.headers, host: '127.0.0.1:8000' },
    }, response => {
      res.writeHead(response.statusCode, response.headers);
      response.pipe(res);
    });
    upstream.setTimeout(30000, () => upstream.destroy(new Error('Backend timed out')));
    upstream.on('error', () => {
      if (!res.headersSent) res.writeHead(502, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ detail: 'Local backend unavailable. Start Django on port 8000.' }));
    });
    req.pipe(upstream);
    return;
  }
  try {
    const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
    const file = path.resolve(root, '.' + (pathname === '/' ? '/index.html' : pathname));
    if (!file.startsWith(root + path.sep)) { res.writeHead(403).end(); return; }
    if (!fs.existsSync(file) || !fs.statSync(file).isFile()) { res.writeHead(404).end(); return; }
    const gzip = /gzip/.test(req.headers['accept-encoding'] || '');
    const key = file + ':' + fs.statSync(file).mtimeMs + ':' + gzip;
    let data = cache.get(key);
    if (!data) {
      const source = fs.readFileSync(file);
      data = gzip ? zlib.gzipSync(source) : source;
      cache.set(key, data);
    }
    res.writeHead(200, {
      'Content-Type': mime[path.extname(file)] || 'application/octet-stream',
      'Content-Length': data.length,
      'Cache-Control': 'no-store',
      'Vary': 'Accept-Encoding',
      ...(gzip ? { 'Content-Encoding': 'gzip' } : {}),
    });
    res.end(req.method === 'HEAD' ? undefined : data);
  } catch (error) { res.writeHead(500).end('Could not serve preview'); }
}).listen(8086, '127.0.0.1', () => console.log('Optimized preview: http://127.0.0.1:8086'));
