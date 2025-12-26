# Code Vision 刷新与本地图片识别问题记录

## 问题

- 场景：Markdown 图片的 Code Vision（下载/上传/CleanShot X）点击后立即更新标签，但有时入口不刷新或消失。
- 原因：下载到本地或上传后，图片文件刚写入磁盘，IDE 的 VFS/索引还没刷新，`MarkdownUtils.illegalImageMark` 用 `FilenameIndex` 查找不到图片，判定为非法标签，导致
  Code Vision 不生成。

## 处理方案

1) **处理链刷新 VFS**  
   在下载/上传链路里追加 `RefreshFileSystemHandler`，写入标签后刷新目录/VFS，确保新文件被立即发现。
2) **校验处兜底刷新**  
   在 `MarkdownUtils.illegalImageMark` 中，当按文件名查找不到图片时，使用 `LocalFileSystem.refreshAndFindFileByIoFile` 再尝试定位刚写入的文件，减少刷新延迟的影响。

## `LocalFileSystem.refreshAndFindFileByIoFile` 示例

```java
// 绝对路径直接刷新查找，若是相对路径可用 project basePath 补全
File file = new File(path);
if (!file.isAbsolute() && project.getBasePath() != null) {
    file = new File(project.getBasePath(), path);
}
VirtualFile refreshed = LocalFileSystem.getInstance().refreshAndFindFileByIoFile(file);
if (refreshed != null) {
    // 刷新成功，可用于后续校验或生成 Code Vision
}
```

## 相关改动

- 下载/上传链路：`MarkdownImageCodeVisionProvider` 中引入 `RefreshFileSystemHandler`。
- 校验兜底：`MarkdownUtils.illegalImageMark` 在按文件名查找失败时尝试 `refreshAndFindFileByIoFile`。***
