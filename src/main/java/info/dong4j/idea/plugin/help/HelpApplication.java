/*
 * MIT License
 *
 * Copyright (c) 2019 dong4j
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

package info.dong4j.idea.plugin.help;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * <p>Company: no company</p>
 * <p>Description: </p>
 *
 * @author dong4j
 * @version 3.0.0
 * @email dong4j @gmail.com
 * @date 2020.01.14 01:52
 * @since 1.0.0
 */
@RestController
@SpringBootApplication
public class HelpApplication {
    /** properties */
    private static Properties properties = new Properties();

    /**
     * Help url map
     *
     * @param where where
     * @return the map
     * @since 1.0.0
     */
    @RequestMapping("/mik/help/{where}")
    public Map<String, String> helpUrl(@PathVariable("where") String where) {
        Map<String, String> result = new HashMap<>(2);
        // todo-dong4j : (2019年03月25日 14:39) [处理 where]
        reload();
        result.put("code", "200");
        result.put("url", properties.getProperty("mik.url"));
        return result;
    }

    /**
     * Main
     *
     * @param args args
     * @since 1.0.0
     */
    public static void main(String[] args) {
        SpringApplication.run(HelpApplication.class);
    }

    /**
     * Reload
     *
     * @since 1.0.0
     */
    private static void reload() {

        try {
            String configPath = System.getProperty("config.path");
            properties.load(new FileReader(configPath + "application.properties"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
