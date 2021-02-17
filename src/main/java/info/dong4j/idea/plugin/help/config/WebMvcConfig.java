package info.dong4j.idea.plugin.help.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

/**
 * <p>Company: 成都返空汇网络技术有限公司 </p>
 * <p>Description: </p>
 *
 * @author dong4j
 * @version 1.0.0
 * @email "mailto:dong4j@fkhwl.com"
 * @date 2021.02.17 00:45
 * @since 1.0.0
 */
@Configuration
public class WebMvcConfig extends WebMvcConfigurerAdapter {

    /** File root path */
    @Value("${web.upload-path}")
    public String fileRootPath;

    /**
     * 资源映射:把请求的/archive/** 映射到该文件根路径
     *
     * @param registry registry
     * @since 1.0.0
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/archive/**").addResourceLocations("file:" + fileRootPath);
    }
}
