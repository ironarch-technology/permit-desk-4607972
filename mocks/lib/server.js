const http = require('http');
const { URL } = require('url');

function readBody(req) {
  return new Promise((resolve) => {
    let raw = '';
    req.on('data', (chunk) => { raw += chunk; });
    req.on('end', () => {
      if (!raw) return resolve({});
      try {
        resolve(JSON.parse(raw));
      } catch (e) {
        resolve({});
      }
    });
  });
}

function start(name, routes) {
  const port = Number(process.env.PORT || 4000);

  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, `http://localhost:${port}`);
    const body = req.method === 'POST' ? await readBody(req) : {};

    for (const route of routes) {
      const match = url.pathname.match(route.path);
      if (match && route.method === req.method) {
        try {
          const result = await route.handle({ params: match.slice(1), query: url.searchParams, body });
          res.writeHead(result.status || 200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(result.body || {}));
        } catch (err) {
          console.error(`[${name}] ${err.message}`);
          res.writeHead(500, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: err.message }));
        }
        return;
      }
    }

    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'no such route' }));
  });

  server.listen(port, () => console.log(`[${name}] listening on ${port}`));
}

function id(prefix) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

module.exports = { start, id };
