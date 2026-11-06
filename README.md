# baidu-uninstall_picture-player

清理百度网盘捆绑的「智能看图」和「智能播放器」组件的 Windows 批处理脚本。

> 仅用于清理自己电脑上的百度网盘捆绑组件。运行前请先退出百度网盘，并建议创建系统还原点。

## 包含脚本

| 文件 | 作用 |
| --- | --- |
| `uninstall-image-viewer.bat` | 卸载百度网盘“智能看图” |
| `uninstall-baidu-smart-player.bat` | 卸载百度网盘“智能播放器” |

## 使用方法

1. 退出百度网盘（包括托盘图标）。
2. 右键对应的 `.bat` 文件，选择“以管理员身份运行”。
3. 按提示确认，等待脚本完成。
4. 重启电脑，或注销后重新登录，使右键菜单和默认应用设置生效。

## 智能看图脚本

脚本会删除以下注册表项：

- `HKEY_CLASSES_ROOT\BaiduNetdiskImageViewerAssociations`
- `HKEY_CURRENT_USER\Software\Baidu\BaiduNetdiskImageViewer`
- `HKEY_CURRENT_USER\Software\RegisteredApplications` 中的 `BaiduNetdiskImageViewer`

并删除程序目录：

```text
%APPDATA%\baidu\BaiduNetdisk\module\ImageViewer
```

**出处**：本脚本根据 [Xzonn 的文章《删除某网盘附带的“智能看图”》](https://xzonn.top/posts/Remove-Intelligent-Image-Viewer.html) 的思路整理。

## 智能播放器脚本

主要操作：

- 结束 `BaiduNetdiskPlayerLaunch.exe` 进程。
- 备份相关注册表到脚本同目录的 `registry-backup`。
- 删除 `BaiduNetdiskPlayerAssociations`、`BaiduNetdiskPlayer.open`、`HKCU\Software\Baidu\BaiduNetdiskPlayer`、`RegisteredApplications` 等注册项。
- 清理播放器接管的视频、音频、图片扩展名关联（`OpenWithProgids`、`OpenWithList`、`UserChoice`）。
- 删除 `module\BrowserEngine\BaiduNetdiskPlayerLaunch.exe`，**不删除**共享的 `BrowserEngine` 目录和百度网盘主程序。

脚本会从注册表读取播放器的实际路径，兼容自定义安装目录。

## 注意事项

- 百度网盘更新后可能会重新安装这些组件，需要重新运行脚本。
- 建议在百度网盘设置中取消“智能看图/智能播放器”的默认关联选项，减少被重新接管的概率。
- 智能播放器脚本会在删除注册表前自动备份到 `registry-backup`；恢复时右键以管理员身份导入对应的 `.reg` 文件。
- 智能看图脚本没有自动备份，建议运行前创建系统还原点。
- `.bat` 文件使用 GBK/ANSI 编码，GitHub 网页上可能显示乱码；下载到 Windows 后右键以管理员身份运行即可。
- 如果删除文件失败，请确认百度网盘已完全退出，或重启后再运行。

## 免责声明

本脚本仅用于清理自己电脑上的百度网盘捆绑组件。删除注册表和文件有风险，请先备份或创建系统还原点。使用本脚本造成的任何后果由使用者自行承担。

## 许可

本仓库未声明开源许可证。转载或分发时请保留 [Xzonn 的原文出处链接](https://xzonn.top/posts/Remove-Intelligent-Image-Viewer.html)。
