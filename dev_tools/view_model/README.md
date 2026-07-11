# YDWE Model Manager

YDWE 模型批量导入 / 3D 预览 / 清理工具。

## 文件说明

| 文件 | 说明 |
|------|------|
| `YdweModelManager.exe` | 主程序，双击运行 |
| `viewer.min.js` | 3D 模型渲染引擎，**必须与 EXE 同目录** |
| `Microsoft.Web.WebView2.WinForms.dll` | WebView2 封装 |
| `Microsoft.Web.WebView2.Core.dll` | WebView2 核心 |
| `WebView2Loader.dll` | WebView2 原生库 (x64) |

## 使用

### 导入模型
1. 打开 EXE → "导入模型"标签
2. 模型来源 → 选择 `.mdx` 所在目录 → 点击"扫描"
3. 目标地图 → 选择 `.w3x` 地图 → 点击"解包"
4. 勾选要导入的模型 → "导入到地图"
5. 用 YDWE 打开地图 → F6 物体编辑器 → 模型已出现在对应面板

### 预览模型
双击模型列表中的条目 → 弹出 3D 预览窗口
- 左键拖拽 = 旋转视角
- 滚轮 = 缩放
- ESC = 关闭

### 清理未使用模型
"清理模型"标签 → 选择地图 → 扫描 → 勾选删除 → 重新打包

## 系统要求

- Windows 10 / 11 (x64)
- .NET Framework 4.x（系统自带）
- [WebView2 运行时](https://go.microsoft.com/fwlink/p/?LinkId=2124703)（Win11 自带；Win10 安装过 Edge 即自带。如预览白屏，点此链接安装）

## 移植给其他开发者

将整个 `dist/` 目录复制过去即可。6 个文件必须放在同一目录下。

EXE 启动时自动检测 YDWE 路径，如找不到会弹出文件夹选择框，选择 YDWE 的 `Build\publish\Release` 目录（包含 `script/` 和 `bin/lua.exe` 的目录）即可。

## 技术栈

- 主程序：C# WinForms，单文件 32KB
- 3D 渲染：WebView2 内嵌 mdx-m3-viewer (WebGL)，支持贴图、旋转、缩放
- BLP 贴图：内建 BLP1 JPEG 解码器
- 地图操作：调用 YDWE 的 w3x2lni CLI 进行 W3X 解包/打包
