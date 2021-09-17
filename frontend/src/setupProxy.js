const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function(app) {
    app.use(
        '/back',
        createProxyMiddleware({
            target: 'http://localhost:9999',
            changeOrigin: true,
        })
    );
};