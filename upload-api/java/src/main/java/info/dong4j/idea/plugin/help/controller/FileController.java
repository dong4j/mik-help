package info.dong4j.idea.plugin.help.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.util.Assert;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 文件上传控制器
 *
 * @author dong4j
 * @since 1.0.0
 */
@RestController
public class FileController {

    @Value("${web.upload-path}")
    private String path;

    /**
     * 文件上传接口
     *
     * @param file    要上传的文件
     * @param request HTTP 请求
     * @return 包含文件访问 URL 的响应
     */
    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> upload(
        @RequestParam("filename") MultipartFile file,
        HttpServletRequest request) {
        
        Assert.isTrue(!file.isEmpty(), "文件为空");

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            return ResponseEntity.badRequest().build();
        }

        // 获取文件扩展名
        String suffix = originalFilename.substring(originalFilename.lastIndexOf(".") + 1) + "/";
        // 生成唯一文件名
        String newFileName = System.currentTimeMillis() + originalFilename;
        String filePath = path + suffix + newFileName;
        
        try {
            File targetFile = new File(filePath);
            if (!targetFile.getParentFile().exists()) {
                targetFile.getParentFile().mkdirs();
            }
            file.transferTo(targetFile);

            // 生成访问 URL
            String urlPath = request.getScheme() + "://"
                             + request.getServerName() + ":"
                             + request.getServerPort()
                             + "/archive/" + suffix + newFileName;

            Map<String, Object> response = new HashMap<>();
            Map<String, String> data = new HashMap<>();
            data.put("url", urlPath);
            response.put("data", data);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
