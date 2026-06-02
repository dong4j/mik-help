# Repository Guidelines

1. **每次回答前后回答结束后都需要叫我:【dong4j】**
2. **我提出的需求必须先给出实现方案并征求确认，确认后才能修改代码**
3. **代码修改完成后使用 compile.sh 编译代码确保没有编译问题**

## 项目结构与模块组织

- `help-api/`：Node.js 单文件帮助文档服务（入口 `help-api/index.js`，配置 `help-api/config.json`）。
- `upload-api/`：多语言上传 API 示例（`upload-api/java/`、`upload-api/kotlin/`、`upload-api/nodejs/`、`upload-api/python/`、`upload-api/golang/`）。
- `site/`：静态文档站点资源（`site/docs.html`、`site/docs/` 文档内容）。
- 根目录脚本：`deploy.sh`、`generate-docs-list.sh` 等运维或文档辅助脚本。

## 构建、测试与本地开发命令

- Help API：`cd help-api && npm run start` 启动服务（默认端口 12346）。
- Upload API（Java）：`cd upload-api/java && mvn clean package`，或 `mvn spring-boot:run`。
- Upload API（Kotlin）：`cd upload-api/kotlin && ./gradlew run`。
- Upload API（Node.js）：`cd upload-api/nodejs && npm install && npm start`。
- Upload API（Python）：`cd upload-api/python && pip install -r requirements.txt && python app.py`。
- Upload API（Go）：`cd upload-api/golang && go run main.go`。

## 编码风格与命名约定

- 代码风格以各语言默认惯例为准，尽量保持现有文件的缩进与格式，不做无关重排。
- Java 包名遵循 `info.dong4j.idea.plugin.help`；HTTP 路由遵循 `/upload`、`/archive/{type}/{filename}`、`/setting/{type}`。
- 新增语言实现请放入 `upload-api/{language}/` 并配套 `README.md` 与启动说明。

## 测试指南

- 当前仓库未提供统一的自动化测试套件，建议用 `curl` 进行端到端验证：
    - `curl -X POST http://localhost:12345/upload -F "filename=@/path/to/image.png"`
    - `curl http://localhost:12346/setting/aliyun_cloud`
- 若新增测试，请在对应语言目录下创建 `tests/` 并在 `README.md` 里补充运行方式。

## 提交与 PR 规范

- 提交信息遵循 Conventional Commits，常见格式如 `feat(scope): ...`、`refactor(docs): ...`、`chore(documentation): ...`。
- PR 需说明改动范围、运行/验证方式，并在新增语言实现时附启动与接口示例。

## 配置与安全提示

- Help API 的配置使用 `help-api/config.json`，可用环境变量 `PORT`、`CONFIG_PATH` 覆盖。
- Upload API 上传目录、大小限制等配置以各实现 README 为准；建议限制文件类型与大小。
