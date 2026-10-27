# DisplayCD — 显示全队技能 CD

在原生队伍 HUD 中显示前台、后台队员元素战技／元素爆发剩余的冷却时间。
PE 版本头或任一必需函数入口不匹配时停止初始化，并写入 DLL 同目录下的 `DisplayCD.log`。

## 设置

在插件商城安装并启用插件后，以下选项默认全部打开：

| 配置节 | 设置 | 行为 |
| --- | --- | --- |
| `ShowElementalSkillCD` | 显示元素战技 CD | 单独控制 E 冷却文字 |
| `ShowElementalBurstCD` | 显示元素爆发 CD | 单独控制 Q 冷却文字 |
| `ShowChargeIndicators` | 显示战技充能次数 | 战技冷却显示期间，使用原生菱形提示可用／恢复次数 |

全部使用 `Type = bool`。插件整体启停使用启动器插件管理中的开关。修改 `config.ini` 后约 250 ms 内重新读取，在下一次原生 HUD 刷新时生效。工作线程发布完整设置快照，HUD 回调只读取快照。插件禁用、DLL 替换需要重启游戏，不支持热卸载。

E／Q 只读取各自开启的技能状态。关闭 Q 显示会恢复原生爆发图标，保留原生能量和交互状态。关闭 E 显示也隐藏充能菱形。菱形模板或充能数据不可用时仍保留有效的 E 冷却文字。冷却按一位小数向上取整，结束后隐藏，不显示误导性的 `0.0`。

位置使用原生行的相对坐标并跟随 UI 缩放，保留原实现的 E／Q 间距和多充能菱形布局。队员重排、队伍 HUD 隐藏或销毁时清理附加对象。

## 安装与商城上架

手动安装时将压缩包内容解压到 `Plugins/SkillCdDisplayPlugin/`，目录内包含 `DisplayCD.dll` 和 `config.ini`。商城 ID 为 `SkillCdDisplayPlugin`，与安装脚本保持一致。

`store/metadata.json` 是商城信息，`store/install.lua` 是安装脚本；更新时备份并恢复已有配置的原始字节，保留用户值、注释、未知键和编码。若宿主取消或退出导致脚本无法继续执行，备份留在 `config.pre-update.ini`，下一次安装先恢复。初始化及配置热重载均不写用户配置。不会读取或改写主插件配置。

## 构建与打包

需要 Windows x64、Visual Studio C++ v145 和 Windows SDK。MinHook 源码已随项目提供。

也可直接打开 `DisplayCD.sln`，构建 Release／x64。DLL 在 `bin/x64/Release/`，构建中间文件在 `obj/`。重建不会覆盖已有输出配置；打包始终使用仓库内的默认配置，避免把本地试用设置带入商城包。

## GitHub Actions 自动发布

推送到 `master` 或在 Actions 中手动运行 `Build and release`，会依次完成：Release x64 构建 → UPX `--best --ultra-brute` 压缩 → UPX 完整性、解压与 Windows DLL 加载检查 → 打包及版本／SHA256 校验 → 上传全部附件 → 公开 GitHub Release。PR 只构建和验证。

基础版本保留在 `config.ini` 和 `store/metadata.json`，两处必须一致，例如 `1.0.0`。Action 自动追加数字后缀 `运行序号 × 100 + 重试次数`：第 7 次运行的首次尝试生成版本 `1.0.0.701`，tag 为 `v1.0.0.701`；重试生成 `1.0.0.702`。使用四段数字以兼容启动器的版本比较，无须手动创建 tag。

构建日志中的插件版本、包内配置、商城信息、ZIP 文件名与 Release tag 使用同一版本。

构建环境使用 Visual Studio 2026／v145；UPX 固定为 5.2.0，并校验官方发布附件的 SHA256。Release 先建立为草稿，全部附件上传成功后才公开。工作流使用仓库自带的 `GITHUB_TOKEN`，仅发布任务具有 `contents: write` 权限，无需额外配置个人令牌。
