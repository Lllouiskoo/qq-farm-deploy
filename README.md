# QQ 农场机器人 Windows 部署方案（无 Docker）

在一台普通 Windows 电脑上部署 [qq-farm-bot](https://github.com/ashu1800/qq-farm-bot)（QQ 农场自动化机器人）并通过 **NapCat 实现 QQ 扫码登录**的完整方案。

**特点：**

- 🐳 **不需要 Docker** —— NapCat 以原生方式运行，低配机器也能跑
- 🔑 **扫码登录 + Code 自动续期** —— 不用反复抓包，过期自动续
- 🚀 **开机自启** —— 一条命令启动 NapCat + 农场面板
- 📦 本仓库只包含**部署方案本身**（脚本 + 插件 + 配置模板 + 教程），不含任何密钥和二进制

---

## 前置条件

| 项 | 要求 | 检查方法 |
|---|---|---|
| 系统 | Windows 10/11 x64 | - |
| QQ 客户端 | **QQ NT 版，版本 ≥ 9.9.27** | QQ 设置 → 关于（如 `9.9.29-47354`，取中间数字 ≥ 40768 即可） |
| Node.js | **≥ 18**（LTS 推荐） | `node -v` |
| pnpm | 任意较新版本 | `pnpm -v`（或用 `corepack enable`） |
| Docker | **不需要** | - |

---

## 目录结构

```
你的工作目录/                    ← start-all.bat 放这里
├── start-all.bat               ← 一键启动（本仓库提供）
├── qq-farm-bot/                ← 第 1 步克隆的农场项目
├── napcat-shell/               ← 第 3 步解压的 NapCat（start-napcat.bat 要复制进去）
└── data/                       ← 运行后自动生成（账号数据，勿外传）

本仓库（qq-farm-deploy）结构：
├── README.md
├── start-all.bat               ← 一键启动脚本
├── install-autostart.bat       ← 安装开机自启（可选）
├── install-autostart.ps1
├── push-to-github.bat          ← 推送/同步到自己的 GitHub（可选）
├── .gitignore
└── napcat/
    ├── start-napcat.bat        ← NapCat 启动器（复制到 napcat-shell/ 里用）
    ├── plugins/qq-miniapp-openauth/   ← 小程序取码插件
    └── config-templates/       ← 配置模板（复制后改 token）
```

---

## 部署步骤

### 第 1 步：克隆农场项目

```bash
git clone https://github.com/ashu1800/qq-farm-bot.git
cd qq-farm-bot
```

> 国内网络如果克隆失败（代理 502 等），用镜像：
> `git clone https://gh-proxy.com/https://github.com/ashu1800/qq-farm-bot.git`

### 第 2 步：安装依赖并构建前端

```bash
pnpm install -r
pnpm build:web
```

### 第 3 步：部署 NapCat（原生，不用 Docker）

1. 到 [NapCatQQ Releases](https://github.com/NapNeko/NapCatQQ/releases) 下载 **`NapCat.Shell.zip`**（约 35MB）
   - ⚠️ 不要用 `NapCat.Shell.Windows.OneKey.zip`（一键包的 QQ 下载链接已失效）
2. 解压，把文件夹改名为 `napcat-shell`，放到 `qq-farm-bot` **同级目录**
3. 把本仓库的 `napcat/start-napcat.bat` 复制进 `napcat-shell/`

### 第 4 步：安装 openauth 插件（扫码取码的关键）

```bash
# 1. 复制插件到 NapCat 的 plugins 目录
cp -r napcat/plugins/qq-miniapp-openauth napcat-shell/plugins/

# 2. 把插件加入白名单（napcat.mjs 里的 Set）
#    找到 "napcat-plugin-qce"，在它后面加一项 "qq-miniapp-openauth"
```

用 Node 一行完成白名单补丁（与官方 Docker entrypoint 逻辑一致）：

```bash
node -e "const fs=require('fs');const p='napcat-shell/napcat.mjs';let s=fs.readFileSync(p,'utf8');const m='\"napcat-plugin-qce\"';if(!s.includes('\"qq-miniapp-openauth\"')){const i=s.indexOf(m);s=s.slice(0,i+m.length)+',\n  \"qq-miniapp-openauth\"'+s.slice(i+m.length);fs.writeFileSync(p,s);console.log('patched')}else console.log('already patched')"
```

### 第 5 步：配置 Token

生成一个随机 token（后面三处要用同一个）：

```bash
node -e "console.log(require('crypto').randomBytes(24).toString('hex'))"
```

然后按模板创建三个配置文件（把 `<你的token>` 换成上面生成的）：

```bash
# NapCat WebUI 配置
mkdir -p napcat-shell/config/plugins/qq-miniapp-openauth
cp napcat/config-templates/webui.example.json        napcat-shell/config/webui.json
cp napcat/config-templates/plugins.example.json      napcat-shell/config/plugins.json
cp napcat/config-templates/openauth-config.example.json napcat-shell/config/plugins/qq-miniapp-openauth/config.json
```

编辑这三个文件，把 token 占位符都替换成同一个值。

> `webui.json` 里 `host: 127.0.0.1` 表示只监听本机（安全）；`napcat-shell/start-napcat.bat` 也支持从同目录的 `napcat-token.txt` 读取 token 覆盖（可选）。

### 第 6 步：配置农场后端环境变量

**CMD（管理员/普通均可），执行 4 条 setx（持久化，重启后仍有效）：**

```bash
setx NAPCAT_LOGIN_ENABLED "true"
setx NAPCAT_WEBUI_URL "http://127.0.0.1:6099/api"
setx NAPCAT_OPENAUTH_URL "http://127.0.0.1:6099/plugin/qq-miniapp-openauth/api"
setx NAPCAT_TOKEN "<你的token>"
```

然后启动农场后端（在 `qq-farm-bot` 目录）：

```bash
pnpm dev:core
```

看到 `admin panel started ... http://localhost:3007` 即成功。

### 第 7 步：启动 NapCat 并扫码

1. **先退出桌面正在运行的 QQ**（NapCat 要启动注入了 hook 的 QQ 实例，同时运行会冲突）
2. 双击 `napcat-shell\start-napcat.bat` → UAC 弹窗点「是」→ QQ 登录窗口出现
3. 浏览器打开 http://localhost:3007 → **添加账号 → QQ 扫码**
4. 用手机 QQ 扫面板上的二维码 → 确认 → 账号自动添加（类型 `qq_napcat`）

### 第 8 步（可选）：开机自启

```bash
install-autostart.bat
```

会在开机启动文件夹创建指向 `start-all.bat` 的快捷方式。之后每次开机自动：NapCat → 5 秒后农场面板。

> 开机时会有一次 UAC 提权弹窗（NapCat 注入 QQ 进程需要管理员权限），点「是」即可。
> 想彻底免弹窗可改用「任务计划程序」以最高权限运行。

---

## 日常使用

- **面板**：http://localhost:3007
- **停止**：关掉 NapCat 窗口会中断 Code 续期导致账号掉线——**最小化即可，不要关**
- **手动补启**：双击工作区根目录的 `start-all.bat`
- **加新账号**：面板 → 添加账号 → QQ 扫码（NapCat 同时只持有一个 QQ 会话，切号时会自动清理，属正常现象）

---

## 常见问题

**Q: 双击 bat 报错 `'xxx' 不是内部或外部命令`？**
bat 文件必须是 **CRLF 换行 + 纯 ASCII 注释**。用记事本另存为选「ANSI」也不会错——本仓库的脚本已处理，勿用会写 LF 换行的编辑器改写。

**Q: NapCat 启动失败/QQ 起不来？**
- 确认 QQ 版本 ≥ 9.9.27
- 确认启动前已退出其他 QQ
- Windows Server 需先安装「媒体基础」组件

**Q: 端口被占用？**
面板 3007、NapCat WebUI 6099、抓包代理 18000。

**Q: 账号掉线了？**
NapCat 窗口被关、或 QQ 被踢下线。重开 `start-napcat.bat`，一般自动快速登录；不行就重新扫码。

**Q: 面板安全吗？**
面板默认无登录鉴权，仅限本机/内网使用。可设 `ADMIN_BIND=127.0.0.1` 只监听回环地址，切勿直接暴露公网。

---

## 文件说明

| 文件 | 作用 |
|---|---|
| `start-all.bat` | 一键启动 NapCat + 农场面板（放在 qq-farm-bot 同级目录） |
| `napcat/start-napcat.bat` | NapCat 启动器（支持 UAC 自提权、可选 token 文件覆盖） |
| `napcat/plugins/qq-miniapp-openauth/` | 小程序取码插件（来自 qq-farm-bot 上游） |
| `napcat/config-templates/` | webui/plugins/插件配置模板 |
| `install-autostart.bat` | 安装开机自启快捷方式 |
| `push-to-github.bat` | 推送本仓库到你自己的 GitHub |

---

## 致谢与来源

- 农场机器人：[ashu1800/qq-farm-bot](https://github.com/ashu1800/qq-farm-bot)
- NapCatQQ：[NapNeko/NapCatQQ](https://github.com/NapNeko/NapCatQQ)
- 本仓库仅整理部署方案与脚本，不含上述项目代码主体；请遵守各上游项目的开源协议与免责声明，合理使用，勿用于违规用途。
