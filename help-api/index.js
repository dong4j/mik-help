/**
 * MIT License
 *
 * Copyright (c) 2019 dong4j
 *
 * MIK Help API - 动态帮助文档服务
 * 为 Markdown Image Kit 插件设置页面提供动态 URL 服务
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

// 配置文件路径
const CONFIG_PATH = process.env.CONFIG_PATH || path.join(__dirname, 'config.json');
const PORT = process.env.PORT || 12346;

// 配置缓存
let config = {};

/**
 * 重新加载配置文件
 * 每次请求都会重新读取配置文件，实现配置热更新
 */
function reloadConfig() {
  try {
    const data = fs.readFileSync(CONFIG_PATH, 'utf8');
    config = JSON.parse(data);
    console.log(`[${new Date().toISOString()}] 配置已重新加载`);
    return true;
  } catch (error) {
    console.error(`[${new Date().toISOString()}] 加载配置文件失败:`, error.message);
    return false;
  }
}

/**
 * 处理 HTTP 请求
 */
const server = http.createServer((req, res) => {
  // 设置 CORS 头
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  // 处理 OPTIONS 请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // 只处理 GET 请求
  if (req.method !== 'GET') {
    res.writeHead(405);
    res.end(JSON.stringify({code: '405', message: 'Method Not Allowed'}));
    return;
  }

  // 解析 URL
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // 健康检查接口
  if (pathname === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({
                             code: '200',
                             status: 'ok',
                             timestamp: Date.now()
                           }));
    return;
  }

  // 匹配路由: /{where}/{type}
  const matches = pathname.match(/^\/([^\/]+)\/([^\/]+)$/);

  if (!matches) {
    // 未匹配到路由，返回默认 URL
    reloadConfig();
    res.writeHead(200);
    res.end(JSON.stringify({
                             code: '200',
                             url: config.defaultUrl || 'https://mik.dong4j.site'
                           }));
    return;
  }

  const where = matches[1];
  const type = matches[2];

  console.log(`[${new Date().toISOString()}] 请求: /${where}/${type}`);

  // 每次请求都重新加载配置
  if (!reloadConfig()) {
    res.writeHead(500);
    res.end(JSON.stringify({
                             code: '500',
                             message: 'Failed to load configuration'
                           }));
    return;
  }

  // 处理 setting 类型的请求
  if (where === 'setting') {
    const helpUrl = config.help && config.help[type];

    if (helpUrl) {
      res.writeHead(200);
      res.end(JSON.stringify({
                               code: '200',
                               url: helpUrl
                             }));
    } else {
      // 如果没有找到对应的帮助链接，返回默认 URL
      res.writeHead(200);
      res.end(JSON.stringify({
                               code: '200',
                               url: config.defaultUrl || 'https://mik.dong4j.site'
                             }));
    }
  } else {
    // 其他类型的请求，返回默认 URL
    res.writeHead(200);
    res.end(JSON.stringify({
                             code: '200',
                             url: config.defaultUrl || 'https://mik.dong4j.site'
                           }));
  }
});

// 启动服务器
server.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║        MIK Help API - 动态帮助文档服务                      ║
║                                                            ║
║        服务已启动: http://localhost:${PORT}                ║
║        配置文件: ${CONFIG_PATH}     ║
║                                                            ║
║        健康检查: http://localhost:${PORT}/health          ║
║        API 格式: http://localhost:${PORT}/{where}/{type}  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
    `);

  // 初始加载配置
  reloadConfig();
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到 SIGTERM 信号，正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n收到 SIGINT 信号，正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});

