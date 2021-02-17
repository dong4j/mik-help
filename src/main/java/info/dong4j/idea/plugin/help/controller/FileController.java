package info.dong4j.idea.plugin.help.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.ResponseEntity;
import org.springframework.util.Assert;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;

/**
 * <p>Company: 成都返空汇网络技术有限公司 </p>
 * <p>Description: </p>
 *
 * @author dong4j
 * @version 1.0.0
 * @email "mailto:dong4j@fkhwl.com"
 * @date 2021.02.17 00:27
 * @since 1.0.0
 */
@RestController
public class FileController {

    /** Path */
    @Value("${web.upload-path}")
    private String path;

    /**
     * Upload
     *
     * @param file 要上传的文件
     * @return response entity
     * @since 1.0.0
     */
    @SuppressWarnings("all")
    @RequestMapping("upload")
    public ResponseEntity<?> upload(@RequestParam("fileName") MultipartFile file, HttpServletRequest request) {
        String filePath;
        Assert.isTrue(!file.isEmpty(), "文件为空");
        // 原始名 以 a.jpg为例
        String originalFilename = file.getOriginalFilename();
        // 获取后缀并拼接'/'用于分类,也可以用日期 例: suffix = "jpg/"
        String suffix = originalFilename.substring(originalFilename.lastIndexOf(".") + 1) + "/";
        // 加上时间戳生成新的文件名,防止重复 newFileName = "1595511980146a.jpg"
        String newFileName = System.currentTimeMillis() + originalFilename;
        filePath = path + suffix + newFileName;
        try {
            File file1 = new File(filePath);
            if (!file1.getParentFile().exists()) {
                file1.getParentFile().mkdirs();
            }
            file.transferTo(file1);
            final String urlPath =
                request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/archive/" + suffix + newFileName;
            return ResponseEntity.ok(new HashMap<String, Object>(2){
                {
                    put("data", new HashMap<String, String>(){
                        {
                            put("url", urlPath);
                        }
                    });
                }
            });
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
