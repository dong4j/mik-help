package info.dong4j.mik

import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.Serializable
import java.io.File
import java.nio.file.Paths

const val UPLOAD_PATH = "./uploads/"
const val SERVER_PORT = 12345

@Serializable
data class UploadResponse(
    val data: UrlData
)

@Serializable
data class UrlData(
    val url: String
)

fun main() {
    // 确保上传目录存在
    File(UPLOAD_PATH).mkdirs()

    embeddedServer(Netty, port = SERVER_PORT) {
        configureRouting()
    }.start(wait = true)
}

fun Application.configureRouting() {
    routing {
        // 文件上传接口
        post("/upload") {
            val multipart = call.receiveMultipart()
            var filename = ""
            var fileBytes: ByteArray? = null

            multipart.forEachPart { part ->
                when (part) {
                    is PartData.FileItem -> {
                        filename = part.originalFileName as String
                        fileBytes = part.streamProvider().readBytes()
                    }

                    else -> {}
                }
                part.dispose()
            }

            if (fileBytes == null || filename.isEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "文件为空"))
                return@post
            }

            // 获取文件扩展名
            val ext = File(filename).extension
            if (ext.isEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "无效的文件扩展名"))
                return@post
            }

            // 创建按类型分类的目录
            val extDir = File(UPLOAD_PATH, ext)
            extDir.mkdirs()

            // 生成唯一文件名
            val timestamp = System.currentTimeMillis()
            val newFilename = "$timestamp$filename"
            val filePath = File(extDir, newFilename)

            // 保存文件
            filePath.writeBytes(fileBytes!!)

            // 生成访问 URL
            val scheme = call.request.origin.scheme
            val host = call.request.host()
            val port = call.request.port()
            val urlPath = "$scheme://$host:$port/archive/$ext/$newFilename"

            val response = UploadResponse(
                data = UrlData(url = urlPath)
            )

            call.respond(response)
            println("File uploaded successfully: $urlPath")
        }

        // 文件预览接口
        get("/archive/{ext}/{filename}") {
            val ext = call.parameters["ext"]!!
            val filename = call.parameters["filename"]!!
            val file = File(UPLOAD_PATH, "$ext/$filename")

            if (file.exists()) {
                call.respondFile(file)
            } else {
                call.respond(HttpStatusCode.NotFound, mapOf("error" to "文件不存在"))
            }
        }

        // 健康检查接口
        get("/health") {
            call.respond(mapOf("status" to "ok"))
        }
    }

    environment.monitor.subscribe(ApplicationStarted) {
        println(
            """
            
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║        MIK Upload API - Kotlin 实现                        ║
║                                                            ║
║        服务已启动: http://localhost:$SERVER_PORT                ║
║        上传路径: $UPLOAD_PATH                           ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
        """.trimIndent()
        )
    }
}

