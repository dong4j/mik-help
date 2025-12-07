# PersonalInfoPanel 集成指南

## 简介

`PersonalInfoPanel` 是一个可复用的个人信息展示组件，专为 IntelliJ IDEA 插件设计。它提供了一个美观、功能丰富的个人信息面板，可以在插件设置页面中展示作者信息，包括头像、姓名、简介、社交媒体链接等。

## 特性

- ✅ **可折叠面板**：默认折叠，点击标题栏可展开/折叠
- ✅ **头像展示**：支持显示头像，鼠标悬停时可切换为另一张图片
- ✅ **社交媒体链接**：支持 GitHub、Blog、Home、Card、Chat、Email、Twitter 等链接
- ✅ **SVG 图标**：使用 SVG 图标替代 emoji，支持主题自适应
- ✅ **命令行卡片**：可展示命令行命令，支持一键复制
- ✅ **响应式设计**：自动适配 IntelliJ IDEA 的亮色/暗色主题

## 快速开始

### 1. 复制 PersonalInfoPanel 类

将 `PersonalInfoPanel.java` 文件复制到你的插件项目中。

**文件位置：**

```
src/main/java/your/package/settings/panel/PersonalInfoPanel.java
```

### 2. 添加必要的依赖

确保你的 `build.gradle.kts` 或 `pom.xml` 中包含以下依赖：

**Gradle (Kotlin DSL):**

```kotlin
dependencies {
    implementation(platform("com.jetbrains.intellij.idea:ideaIC:2023.2"))
    implementation("com.jetbrains.intellij.idea:ideaIC")
}
```

**Maven:**

```xml
<dependencies>
    <dependency>
        <groupId>com.jetbrains.intellij.idea</groupId>
        <artifactId>ideaIC</artifactId>
        <version>2023.2</version>
    </dependency>
</dependencies>
```

### 3. 准备资源文件

#### 3.1 头像图片

准备两张头像图片（推荐尺寸：120x120 像素）：

- `avatar.png` - 默认头像
- `avatar2.png` - 悬停时的头像（可选）

将图片放在 `src/main/resources/icons/personal/` 目录下。

#### 3.2 SVG 图标（可选）

如果需要使用 SVG 图标替代默认的 emoji，准备以下 SVG 文件：

- `github.svg`
- `blog.svg`
- `home.svg`
- `card.svg`
- `chat.svg`
- `email.svg`

将 SVG 文件放在 `src/main/resources/icons/personal/` 目录下。

### 4. 在设置页面中集成

在你的设置页面类中（实现 `SearchableConfigurable` 接口），添加以下代码：

```java
import your.package.settings.panel.PersonalInfoPanel;
import javax.swing.ImageIcon;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.net.URL;

public class YourSettingsPage implements SearchableConfigurable {
    
    // ... 其他代码 ...
    
    /**
     * 创建个人信息面板
     */
    @NotNull
    private PersonalInfoPanel createPersonalInfoPanel() {
        // 加载头像图片
        ImageIcon avatar = loadImageIcon("/icons/personal/avatar.png");
        ImageIcon hoverAvatar = loadImageIcon("/icons/personal/avatar2.png");
        
        // 构建个人信息配置
        PersonalInfoPanel.PersonalInfo info = PersonalInfoPanel.PersonalInfo.builder()
            .name("Your Name")
            .role("Your Role | Your Title")
            .bio("Your bio description here.<br><br>" +
                 "You can use HTML tags for formatting.")
            .avatar(avatar)
            .hoverAvatar(hoverAvatar)
            .command("your-command --option")  // 可选：命令行命令
            .githubUrl("https://github.com/yourusername")
            .blogUrl("https://your-blog.com")
            .websiteUrl("https://your-website.com")
            .npxCardUrl("https://your-npx-card.com")  // 可选
            .chatUrl("https://your-chat.com")  // 可选
            .email("your-email@example.com")
            .twitterUrl("https://twitter.com/yourusername")  // 可选
            .footerGitHubUrl("https://github.com/yourusername/your-plugin")
            .build();
        
        return new PersonalInfoPanel(info);
    }
    
    /**
     * 加载图片资源
     */
    @Nullable
    private ImageIcon loadImageIcon(@NotNull String resourcePath) {
        try {
            URL imageUrl = getClass().getResource(resourcePath);
            if (imageUrl != null) {
                BufferedImage image = ImageIO.read(imageUrl);
                if (image != null) {
                    return new ImageIcon(image);
                }
            }
        } catch (Exception e) {
            // 处理异常
        }
        return null;
    }
    
    /**
     * 构建主面板
     */
    @NotNull
    private JPanel buildMainPanel() {
        JPanel mainPanel = new JPanel(new BorderLayout());
        
        // ... 其他设置面板 ...
        
        // 添加个人信息面板
        PersonalInfoPanel personalInfoPanel = createPersonalInfoPanel();
        mainPanel.add(personalInfoPanel.getContent(), BorderLayout.SOUTH);
        
        return mainPanel;
    }
}
```

## 配置选项

### PersonalInfo 配置项

| 配置项               | 类型        | 必填 | 说明                 |
|-------------------|-----------|----|--------------------|
| `name`            | String    | 是  | 姓名                 |
| `role`            | String    | 否  | 职位/角色              |
| `bio`             | String    | 否  | 个人简介（支持 HTML）      |
| `avatar`          | ImageIcon | 否  | 头像图标               |
| `hoverAvatar`     | ImageIcon | 否  | 悬停时的头像图标           |
| `githubUrl`       | String    | 否  | GitHub 链接          |
| `blogUrl`         | String    | 否  | 博客链接               |
| `websiteUrl`      | String    | 否  | 个人网站链接             |
| `email`           | String    | 否  | 邮箱地址               |
| `twitterUrl`      | String    | 否  | Twitter/X 链接       |
| `npxCardUrl`      | String    | 否  | NPX Card 链接        |
| `chatUrl`         | String    | 否  | Chat 链接            |
| `command`         | String    | 否  | 命令行命令（会显示为可复制的代码块） |
| `footerGitHubUrl` | String    | 否  | 底部提示的 GitHub 链接    |

## 完整示例

### 最小配置示例

```java
PersonalInfoPanel.PersonalInfo info = PersonalInfoPanel.PersonalInfo.builder()
    .name("John Doe")
    .githubUrl("https://github.com/johndoe")
    .footerGitHubUrl("https://github.com/johndoe/my-plugin")
    .build();

PersonalInfoPanel panel = new PersonalInfoPanel(info);
```

### 完整配置示例

```java
// 加载头像
ImageIcon avatar = loadImageIcon("/icons/personal/avatar.png");
ImageIcon hoverAvatar = loadImageIcon("/icons/personal/avatar2.png");

PersonalInfoPanel.PersonalInfo info = PersonalInfoPanel.PersonalInfo.builder()
    .name("John Doe")
    .role("✨ Senior Developer | 🛠️ Plugin Creator")
    .bio("Passionate about creating useful developer tools.<br><br>" +
         "💡 Connect with me:")
    .avatar(avatar)
    .hoverAvatar(hoverAvatar)
    .command("npx johndoe --help")
    .githubUrl("https://github.com/johndoe")
    .blogUrl("https://blog.johndoe.com")
    .websiteUrl("https://johndoe.com")
    .npxCardUrl("https://npx-card.johndoe.com")
    .chatUrl("https://chat.johndoe.com")
    .email("john@example.com")
    .twitterUrl("https://twitter.com/johndoe")
    .footerGitHubUrl("https://github.com/johndoe/my-plugin")
    .build();

PersonalInfoPanel panel = new PersonalInfoPanel(info);
```

## 自定义样式

### 修改头像尺寸

默认头像尺寸为 120x120 像素。如果需要修改，可以：

1. 准备相应尺寸的图片
2. 图片会自动居中显示，无需额外配置

### 自定义 SVG 图标

如果不想使用默认的 SVG 图标，可以：

1. 准备自定义的 SVG 文件
2. 修改 `PersonalInfoPanel.java` 中的 `loadSvgIcon()` 方法，指向你的 SVG 文件路径

### 修改颜色主题

面板会自动适配 IntelliJ IDEA 的主题。如果需要自定义颜色：

1. 修改 `PersonalInfoPanel.java` 中的颜色常量
2. 悬停颜色：`new Color(102, 126, 234)` (紫色 #667eea)

## 注意事项

1. **头像图片**：推荐使用 120x120 像素的圆形头像，PNG 格式，支持透明背景
2. **SVG 图标**：SVG 图标会根据 IntelliJ IDEA 的主题自动调整颜色
3. **HTML 支持**：`bio` 字段支持 HTML 标签，可以使用 `<br>`、`<div>` 等标签进行格式化
4. **链接点击**：所有链接都支持点击，会自动在浏览器中打开
5. **折叠状态**：面板默认折叠，不会保存折叠状态（每次打开设置页面都是折叠状态）

## 常见问题

### Q: 头像不显示怎么办？

A: 检查以下几点：

- 图片路径是否正确
- 图片文件是否存在于 `src/main/resources/icons/personal/` 目录
- 图片格式是否为 PNG
- `loadImageIcon()` 方法是否正确实现

### Q: SVG 图标不显示怎么办？

A: 检查以下几点：

- SVG 文件是否存在
- SVG 文件路径是否正确
- `loadSvgIcon()` 方法中的路径是否正确

### Q: 链接无法点击怎么办？

A: 确保：

- 使用了 `BrowserUtil.browse()` 方法
- 鼠标监听器已正确添加
- 链接 URL 格式正确

### Q: 如何隐藏某些链接？

A: 在构建 `PersonalInfo` 时，不设置对应的 URL 即可。例如，如果不想要 Twitter 链接，就不调用 `.twitterUrl()` 方法。

## 许可证

该组件遵循原项目的许可证。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个组件。

## 更新日志

### v1.0.0 (2025.12.07)

- 初始版本
- 支持头像展示（含悬停效果）
- 支持社交媒体链接
- 支持 SVG 图标
- 支持可折叠面板
- 支持命令行卡片
- 支持主题自适应

