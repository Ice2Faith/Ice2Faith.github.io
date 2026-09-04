# Docs Site 快速上手

## 简介

Docs Site 是一个纯前端的静态文档查看器，无需构建工具或后端服务，只需将 Markdown 文件放置在任意静态文件服务器上即可在线浏览。

**核心特性：**

- Markdown 渲染（代码高亮、数学公式、Mermaid 图表）
- 自动目录导航与滚动高亮
- 深色 / 浅色主题切换
- 文档内链接自动拦截为站内跳转
- 图片、视频、音频、PDF 内联预览
- 打印支持
- 移动端响应式布局

## 目录结构

```
docs-site/
├── assets/                 # 样式与背景图
│   ├── app.css             # 应用主样式
│   ├── markdown-styles.css # Markdown 渲染样式
│   ├── markdown-setup.js   # markdown-it 初始化与插件配置
│   └── bgimg.jpg           # 默认背景图
├── components/             # Vue 组件
│   └── App.vue             # 根组件（文档查看器主体）
├── lib/                    # 第三方库（Vue、markdown-it、highlight.js、KaTeX、Mermaid 等）
├── vue2-loader/            # Vue2Loader 组件加载器
├── index.html              # 入口页面
├── manifest.json           # 站点配置文件
└── readme.md               # 本文档（默认首页）
```

## manifest.json 配置

`manifest.json` 是站点的唯一配置文件，放在与 `index.html` 同级目录下，运行时自动加载。

```json
{
  "title": "Docs Site",
  "index": "./readme.md",
  "background": "./assets/bgimg.jpg"
}
```

| 字段         | 说明                                           | 必填 |
| ------------ | ---------------------------------------------- | ---- |
| `title`      | 站点标题，显示在顶部导航栏和浏览器标签页       | 否   |
| `index`      | 首页文档的相对路径（打开站点时默认加载的文件） | 否   |
| `background` | 页面背景图片的相对路径                         | 否   |

> 所有字段均可省略。省略时使用默认值：标题为 `Docs`，首页为 `readme.md`，背景为空。

## 使用方式

Docs Site 支持两种使用方式：**主站点部署**和**二级路径共享资源部署**。

### 方式一：主站点部署

主站点即 `docs-site` 目录本身，所有静态资源（库文件、组件、样式等）都存放在此目录下。

**步骤：**

1. 将 `docs-site` 目录部署到任意静态文件服务器（如 Nginx、GitHub Pages 等）
2. 编辑 `manifest.json`，配置站点标题、首页文档路径和背景图
3. 编写 Markdown 文档，放在 `docs-site` 目录下的任意位置
4. 访问 `index.html` 即可查看文档

**示例：** 在 `docs-site` 下创建了 `docs/guide.md`，将 `manifest.json` 的 `index` 改为 `./docs/guide.md`，或通过 URL hash 导航：`index.html#docs/guide.md`。

### 方式二：二级路径共享资源部署

如果需要在同一站点下部署多个独立的文档入口（如不同项目的文档），可以通过**共享主站点资源**的方式实现，无需重复复制 `lib`、`components`、`vue2-loader` 等资源目录。

#### 原理

二级路径文档只需要两个文件：

- `index.html` — 入口页面，直接从主站点复制，然后修改静态资源路径指向主站点目录即可
- `manifest.json` — 配置文件，指定当前文档入口和标题

通过在 `index.html` 中使用相对路径引用主站点的资源，即可复用全部依赖，实现一套资源、多个文档入口。

#### 目录结构示例

```
/
├── docs-site/              # 主站点（包含全部资源）
├── project-a/              # 二级路径文档 A
│   ├── index.html
│   ├── manifest.json
│   └── docs/
│       └── readme.md
├── project-b/              # 二级路径文档 B
│   ├── index.html
│   ├── manifest.json
│   └── docs/
│       └── readme.md
```

#### 操作步骤

**第一步：复制主站点文件**

将主站点的 `index.html` 和 `manifest.json` 复制到新文档目录下。

**第二步：修改 manifest.json**

修改 `manifest.json`，配置当前文档的标题和入口文件：

```json
{
  "title": "Project A Docs",
  "index": "./docs/readme.md",
  "background": "../docs-site/assets/bgimg.jpg"
}
```

> `background` 路径需要指向主站点的资源目录。

**第三步：修改 index.html 中的资源路径**

将复制过来的 `index.html` 中所有静态资源路径从 `./` 前缀改为 `../docs-site/` 前缀。

需要替换的路径前缀对照：

| 原始路径前缀       | 替换为                       |
| ------------------ | ---------------------------- |
| `./lib/`           | `../docs-site/lib/`          |
| `./vue2-loader/`   | `../docs-site/vue2-loader/`  |
| `./assets/`        | `../docs-site/assets/`       |
| `./components/`    | `../docs-site/components/`   |

替换后的关键引用示例：

```html
<!-- 库文件引用 -->
<script src="../docs-site/lib/vue/vue-2.js"></script>
<script src="../docs-site/vue2-loader/loader/Vue2Loader.js"></script>
<script src="../docs-site/lib/markdown-it@14.1.1/dist/markdown-it.min.js"></script>

<!-- 样式引用 -->
<link rel="stylesheet" href="../docs-site/assets/markdown-styles.css">
<link rel="stylesheet" href="../docs-site/assets/app.css">
```

Mermaid ESM 导入也需要同样的路径替换：

```html
<script type="module">
    import mermaid from '../docs-site/lib/mermaid@11/dist/mermaid.esm.min.mjs';
    mermaid.initialize({startOnLoad: false});
    window.mermaid = mermaid;
</script>
```

Vue2Loader 加载根组件的路径也需修改：

```html
<script>
    Vue2Loader.createVue('../docs-site/components/App.vue', 'app').then(function (app) {
        window.app = app;
        let md = setupMarkdown((url) => {
            return window.app.resolvePath(window.app.currentFilePath, url)
        });
        window.app.$md = md;
    });
</script>
```

**第四步：编写文档**

在新文档目录下编写 Markdown 文档，访问对应的 `index.html` 即可查看。

#### 路径层级说明

如果二级路径嵌套更深（如 `projects/sub/my-project/`），只需将所有资源引用前缀相应调整为指向主站点目录即可，例如 `../../docs-site/lib/...`。

核心原则：**确保 `index.html` 中所有资源路径能正确访问到主站点的 `lib`、`components`、`vue2-loader`、`assets` 目录**。

## 文档编写规范

### Markdown 支持

- 标准 Markdown 语法（标题、列表、表格、引用、代码块等）
- GFM 扩展（任务列表、删除线等）
- 代码块语法高亮（支持 Java、Python、JavaScript、SQL、XML、YAML 等数十种语言）
- 数学公式（KaTeX，行内 `$...$` 和块级 `$$...$$`）
- Mermaid 图表（使用 ` ```mermaid ` 代码块）

### 文档内导航

Markdown 中的链接支持以下行为：

- **链接到其他 `.md` 文件**：自动拦截为站内跳转，无需刷新页面
  ```markdown
  [查看指南](./guide.md)
  ```
- **链接到文本/代码文件**（`.java`、`.py`、`.xml`、`.json` 等）：自动以代码块形式渲染
- **链接到外部 URL**：在新标签页中打开
- **链接到图片/视频/PDF**：自动内联预览

### URL Hash 导航

可以通过 URL hash 直接指定要查看的文件：

```
index.html#docs/guide.md
index.html#docs/advanced/config.md
```

## 本地预览

### 方式一：直接打开（`file://` 协议）

由于 Vue2Loader 内部代理了 `window.fetch`，通过链式降级策略（JSONP → iframe → File System API）支持在 `file://` 协议下加载本地文件，因此可以直接双击 `index.html` 打开查看。

> **注意：** 此方式下大部分功能正常可用，但 Mermaid 图表（依赖 ESM 动态导入）在 `file://` 协议下无法加载，如需完整体验请使用方式二。

### 方式二：启动本地服务器（推荐）

如需完整功能（包括 Mermaid 图表渲染），推荐使用以下任一方式启动本地服务器：

```bash
# Python
python -m http.server 8080

# Node.js (npx)
npx serve .

# Node.js (http-server)
npx http-server -p 8080
```

然后访问 `http://localhost:8080/docs-site/` 即可预览。

## 技术支持

本页面由 [Docs Site](./) 和 [Vue2Loader](../vue2-loader/) 提供支持。

- **Docs Site** — 纯前端静态文档查看器，负责 Markdown 渲染、目录导航、主题切换等核心功能
- **Vue2Loader** — 无构建工具的 Vue 2 单文件组件运行时加载器，负责组件动态加载与资源解析
