module.exports = {
  apps: [
    {
      name: 'mik-help-api', // 应用名称
      namespace: 'mik', // 指定命名空间
      version: '1.0.0', // 应用版本
      cwd: '/Users/dong4j/Developer/MIK/help-api', // 当前工作目录
      script: './index.js', // 主脚本路径，相对于 cwd
      watch: true, // 是否启用文件监控
      ignore_watch: ['node_modules', 'logs'], // 忽略监控的文件或目录
      exec_mode: "fork",
      instances: 1, // 应用实例数量
      autorestart: true, // 是否自动重启
      env: {
        PORT: 12345
      },
      log_date_format: "YYYY-MM-DD HH:mm:ss", // 日志时间格式
      error_file: './logs/error.log', // 错误日志文件
      out_file: './logs/out.log', // 输出日志文件
      merge_logs: true, // 是否合并日志
    },
  ],
};

