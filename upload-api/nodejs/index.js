/**
 * MIK Upload API - Node.js 实现
 * 使用 Express 和 Multer 提供文件上传和预览服务
 */

const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 12345;
const UPLOAD_PATH = process.env.UPLOAD_PATH || './uploads/';

// 确保上传目录存在
if (!fs.existsSync(UPLOAD_PATH)) {
  fs.mkdirSync(UPLOAD_PATH, {recursive: true});
}

// 配置 Multer 存储
const storage = multer.diskStorage({
                                     destination: function (req, file, cb) {
                                       // 根据文件扩展名创建目录
                                       const ext = path.extname(file.originalname).slice(1);
                                       const extDir = path.join(UPLOAD_PATH, ext);

                                       if (!fs.existsSync(extDir)) {
                                         fs.mkdirSync(extDir, {recursive: true});
                                       }

                                       cb(null, extDir);
                                     },
                                     filename: function (req, file, cb) {
                                       // 生成唯一文件名
                                       const timestamp = Date.now();
                                       const newFileName = timestamp + file.originalname;
                                       cb(null, newFileName);
                                     }
                                   });

const upload = multer({
                        storage: storage,
                        limits: {
                          fileSize: 10 * 1024 * 1024 // 10 MB
                        }
                      });

/**
 * 文件上传接口
 */
app.post('/upload', upload.single('fileName'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({error: '没有文件'});
  }

  // 获取文件扩展名
  const ext = path.extname(req.file.originalname).slice(1);
  const fileName = req.file.filename;

  // 生成访问 URL
  const protocol = req.protocol;
  const host = req.get('host');
  const urlPath = `${protocol}://${host}/archive/${ext}/${fileName}`;

  res.json({
             data: {
               url: urlPath
             }
           });

  console.log(`File uploaded successfully: ${urlPath}`);
});

/**
 * 文件预览接口
 */
app.use('/archive', express.static(UPLOAD_PATH));

/**
 * 健康检查接口
 */
app.get('/health', (req, res) => {
  res.json({status: 'ok'});
});

/**
 * 错误处理
 */
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({error: '文件太大'});
    }
    return res.status(400).json({error: error.message});
  }
  res.status(500).json({error: '服务器错误'});
});

/**
 * 启动服务器
 */
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║        MIK Upload API - Node.js 实现                       ║
║                                                            ║
║        服务已启动: http://localhost:${PORT}                ║
║        上传路径: ${UPLOAD_PATH}                 ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
    `);
});

