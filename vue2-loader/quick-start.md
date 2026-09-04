# Vue2Loader 快速开始

> **版本：** Vue2Loader.js v1.0  
> **依赖：** Vue 2.x（全局引入）  
> **定位：** 无需构建工具（webpack / vite），直接在多页应用 HTML 中使用 `.vue` 单文件组件进行开发

---

## 一、概述

Vue2Loader 是一个轻量级运行时加载器，核心能力是**在浏览器中直接解析并加载 `.vue` 单文件组件**，让开发者在不用
webpack、vue-cli 等构建工具的前提下，也能享受 `.vue` 组件化开发的体验。

**适用场景：**

- 内部工具、文档站点、运维面板等不想引入构建流程的页面
- 需要在纯静态服务器（甚至 `file://` 协议）上运行的 Vue 应用
- 希望保留 `.vue` 文件结构，同时保持部署简单性的项目

**核心原理：**

1. 通过 XHR / fetch 获取 `.vue` 文件文本
2. 按行解析，分离 `<template>`、`<script>`、`<style>`、`<header>` 四个块
3. 将 `export default {` 替换为 `window.xxx = {`，注入 `<script>` 标签执行
4. 将 template 文本挂载到全局，注入到 Vue options 中
5. 递归解析 components / mixins / directives / objects 中的 URL 字符串依赖
6. 最终调用 `new Vue(options)` 完成挂载

---

## 二、核心特性

| 特性          | 说明                                                           |
|-------------|--------------------------------------------------------------|
| `.vue` 文件加载 | 支持 `<template>` / `<script>` / `<style>` / `<header>` 四个块    |
| 组件 URL 注册   | `components: { CompName: './Comp.vue' }` 自动递归加载              |
| 混入 URL 加载   | `mixins: ['./mixin.js']` 自动加载并合并                             |
| 指令 URL 注册   | `directives: { show: './show.js' }` 自动注册为全局指令                |
| 对象挂载        | `objects: { rsa: './rsa.js' }` 将对象挂载到 `Vue.prototype`        |
| 仿 scoped 样式 | 使用 `.--this` 选择器模拟 scoped 效果                                 |
| Header 注入   | `.vue` 中的 `<header>` 块内容注入到 `<head>`，可设置 `<title>` 等         |
| 本地文件支持      | 通过 JSONP / iframe / File System API 链式降级支持 `file://` 协议      |
| 递归依赖解析      | 组件的组件、混入的混入，均自动递归加载                                          |
| Loader 辅助方法 | 每个组件自动注入 `loaderHref()` / `loaderUrl()` / `loaderResource()` |

---

## 三、快速开始

### 3.1 最小示例

**index.html**

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Vue2Loader 示例</title>
    <!-- 1. 引入 Vue 2 -->
    <script src="./lib/vue-2.js"></script>
    <!-- 2. 引入 Vue2Loader -->
    <script src="./vue2-loader/loader/Vue2Loader.js"></script>
</head>
<body>
<!-- 3. 挂载点 -->
<div id="app"></div>

<!-- 4. 加载根组件 -->
<script>
    Vue2Loader.createVue('./components/app.vue', 'app')
</script>
</body>
</html>
```

**components/app.vue**

```html

<template>
    <div class="app">
        <h1>{{ message }}</h1>
        <child-comp/>
    </div>
</template>

<header>
    <title>我的应用</title>
</header>

<script>
    export default {
        name: 'App',
        components: {
            ChildComp: './ChildComp.vue'   // 用 URL 字符串声明子组件
        },
        data() {
            return {
                message: 'Hello Vue2Loader!'
            }
        }
    }
</script>

<style>
    .app {
        color: #333;
        font-family: sans-serif;
    }
</style>
```

**components/ChildComp.vue**

```html

<template>
    <div class="child">
        <p>子组件：{{ info }}</p>
    </div>
</template>

<script>
    export default {
        name: 'ChildComp',
        data() {
            return {info: '我是通过 URL 加载的子组件'}
        }
    }
</script>

<style>
    .child {
        color: dodgerblue;
    }
</style>
```

> **注意：** 需要通过 HTTP 服务器访问（如 `python -m http.server` 或 nginx），不能直接双击打开 HTML 文件。若需在 `file://`
> 协议下运行，请参阅 [第九节](#九本地文件协议file支持)。

---

### 3.2 `createVue` 参数说明

```javascript
Vue2Loader.createVue(url, domId)
```

| 参数      | 类型       | 默认值     | 说明                         |
|---------|----------|---------|----------------------------|
| `url`   | `string` | —       | 根 `.vue` 文件的 URL（相对或绝对）    |
| `domId` | `string` | `'app'` | 挂载元素的 ID（不含 `#`），找不到时会自动创建 |

**返回值：** `Promise<Vue>` — resolve 后得到 `new Vue(options)` 的实例。

```javascript
Vue2Loader.createVue('./components/app.vue', 'app').then(function (app) {
    window.app = app;   // 保存实例，供后续使用
});
```

---

## 四、`.vue` 文件结构

Vue2Loader 支持四个顶级块，顺序不限，但**开始/结束标签必须独占一行**：

```
<template>  ...  </template>   — 组件模板（必填）
<header>    ...  </header>     — 注入到 <head> 的 HTML（可选）
<script>    ...  </script>     — 组件选项，必须 export default（必填）
<style>     ...  </style>      — 组件样式（可选）
```

### 4.1 `<template>` 块

与普通 `.vue` 文件相同，支持所有 Vue 2 模板语法（`v-if`、`v-for`、`@click`、插值表达式等）。

### 4.2 `<header>` 块（非标准扩展）

Vue2Loader 特有的扩展块。`<header>` 内的 HTML 内容会在组件加载时**追加到 `document.head` 末尾**，常用于设置页面标题：

```html

<header>
    <title>技术全景文档</title>
    <!-- 也可以包含 meta、link 等 -->
</header>
```

> 若多个组件都包含 `<header>` 块，后加载的会覆盖先加载的 `<title>`（只保留最后一个）。

### 4.3 `<script>` 块

**必须使用 `export default { ... }` 导出组件选项对象**，语法与 vue-cli 项目完全一致。

**限制：**

- ❌ 不能使用 `import` / `require` 导入其他模块
- ❌ 不能 `export` 除 `default` 以外的内容
- ✅ 组件依赖通过 `components` 中的 **URL 字符串** 声明（详见第五节）
- ✅ 混入通过 `mixins` 中的 **URL 字符串** 声明

```html

<script>
    export default {
        name: 'MyComponent',
        components: {
            OtherComp: './OtherComp.vue'    // URL 字符串，非 import
        },
        mixins: ['./mixins/common.js'],     // URL 字符串，非 import
        data() {
            return {count: 0}
        },
        methods: {
            increment() {
                this.count++
            }
        }
    }
</script>
```

### 4.4 `<style>` 块

支持普通 CSS 写法。**`scoped` 属性不会被真正处理**，但提供了 `.--this` 选择器机制来模拟 scoped 效果（详见第七节）。

---

## 五、依赖解析系统

Vue2Loader 的核心能力是**递归解析 URL 字符串依赖**。在 `export default {}` 中，以下四个属性支持 URL 字符串写法，加载器会自动将其替换为真实对象：

### 5.1 `components` — 局部组件注册

```javascript
components: {
    ChildA: './ChildA.vue',           // 相对当前 .vue 文件的路径
        ChildB
:
    '../shared/ChildB.vue',   // 支持相对路径
        ChildC
:
    '/abs/path/ChildC.vue'    // 支持绝对路径
}
```

**处理流程：**

1. 加载 `.vue` 文件 → 解析为 options 对象
2. 递归解析该组件自身的依赖
3. 调用 `Vue.extend(options)` 生成组件构造器
4. 替换原来的 URL 字符串

### 5.2 `mixins` — 局部混入

```javascript
mixins: ['./mixins/logger.js', './mixins/validator.js']
```

混入文件是普通 `.js` 文件，同样使用 `export default {}` 导出混入选项对象：

```javascript
// mixins/logger.js
export default {
    methods: {
        log(msg) {
            console.log('[LOG]', msg)
        }
    }
}
```

### 5.3 `directives` — 全局指令注册

```javascript
directives: {
    focus: './directives/focus.js',
        tooltip
:
    './directives/tooltip.js'
}
```

指令文件同样使用 `export default {}` 导出指令定义对象：

```javascript
// directives/focus.js
export default {
    inserted(el) {
        el.focus()
    }
}
```

> 注意：通过 URL 加载的指令会自动调用 `Vue.directive(name, definition)` 进行**全局注册**。

### 5.4 `objects` — 挂载到 Vue.prototype

```javascript
objects: {
    rsa: './utils/rsa.js',
        config
:
    './utils/config.js'
}
```

加载后，对象会挂载到 `Vue.prototype` 上，所有组件实例中可通过 `this.rsa`、`this.config` 访问：

```javascript
// utils/rsa.js
export default {
    encrypt(text) { /* ... */
    },
    decrypt(text) { /* ... */
    }
}

// 在任意组件中使用
methods: {
    doEncrypt()
    {
        this.rsa.encrypt(this.plainText)
    }
}
```

### 5.5 依赖解析路径规则

所有 URL 路径都是**相对于当前 `.vue` 文件所在目录**解析的，使用 `new URL(value, baseHref).href` 计算绝对路径。

```
项目结构：
├── index.html
├── components/
│   ├── app.vue            ← 根组件，baseHref = /components/app.vue
│   ├── ChildA.vue         ← app.vue 中写 './ChildA.vue'
│   └── shared/
│       └── ChildB.vue     ← app.vue 中写 './shared/ChildB.vue'
```

---

## 六、核心 API 参考

### 6.1 创建应用

| 方法          | 签名                                  | 说明                              |
|-------------|-------------------------------------|---------------------------------|
| `createVue` | `(url, domId='app') → Promise<Vue>` | 加载 `.vue` 并 `new Vue()` 挂载到指定元素 |

### 6.2 加载组件

| 方法                     | 签名                                 | 说明                                        |
|------------------------|------------------------------------|-------------------------------------------|
| `loadVueOptions`       | `(url) → Promise<Object>`          | 加载 `.vue` 文件，返回含 `template` 的 options 对象  |
| `loadVueComponent`     | `(url) → Promise<Function>`        | 加载并返回 `Vue.extend(options)` 构造器           |
| `registryVueComponent` | `(url, name?) → Promise<Function>` | 加载并调用 `Vue.component(name, options)` 全局注册 |
| `registryVueDirective` | `(url, name?) → Promise<Function>` | 加载并调用 `Vue.directive(name, options)` 全局注册 |

### 6.3 加载普通对象

| 方法           | 签名                        | 说明                                   |
|--------------|---------------------------|--------------------------------------|
| `loadObject` | `(url) → Promise<Object>` | 加载 `.js` 文件中 `export default {}` 的对象 |

### 6.4 资源获取

| 方法            | 签名                                    | 说明                                                      |
|---------------|---------------------------------------|---------------------------------------------------------|
| `fetchUrl`    | `(url) → Promise<string>`             | 链式降级获取文件内容（fetch → xhr → axios → jsonp → iframe → file） |
| `fetchXhr`    | `(url, options?) → Promise<string>`   | 使用 XMLHttpRequest 获取                                    |
| `fetchJsonp`  | `(url, options?) → Promise<Response>` | 使用 JSONP 获取（适用于 `file://` 协议）                           |
| `fetchIframe` | `(url) → Promise<string>`             | 使用 iframe 预加载获取（适用于 `file://` 协议）                       |
| `fetchFile`   | `(url) → Promise<Response>`           | 使用 File System API 从本地文件系统获取                            |

### 6.5 工具方法

| 方法                 | 签名                         | 说明                                                            |
|--------------------|----------------------------|---------------------------------------------------------------|
| `appendHeader`     | `(headerHtml) → void`      | 将 HTML 追加到 `document.head`，重复 `<title>` 只保留最后一个               |
| `parseVueTemplate` | `(html) → Object`          | 将 `.vue` 文本解析为 `{ template, script, style, header, varName }` |
| `notify`           | `(content, level?) → void` | 显示右上角弹出通知，level: `primary/info/warning/danger/success`        |
| `copyToClipboard`  | `(text) → void`            | 复制文本到剪贴板                                                      |

---

## 七、仿 Scoped 样式（`.--this` 机制）

Vue2Loader **不真正处理** `scoped` 属性。但提供了 `.--this` 选择器替换机制，达到类似 scoped 的效果。

### 工作原理

1. 加载组件时，为根元素生成唯一 class：`vue-scoped-style-XXXXXX`
2. 将该 class 追加到 template 根元素的 `class` 属性上
3. 将 `<style>` 中的 `.--this` 全部替换为 `.vue-scoped-style-XXXXXX`

### 使用方式

```html

<template>
    <div class="my-comp">
        <span>文本</span>
        <p>段落</p>
    </div>
</template>

<style>
    /* 普通样式 — 全局生效，可能污染其他组件 */
    span {
        color: gray;
    }

    /* .--this 样式 — 仅限本组件根元素下生效 */
    .--this {
        background: lightseagreen;
    }

    .--this span {
        color: coral; /* 只影响本组件内的 span */
    }
</style>
```

上例中，`.--this` 会被替换为 `.vue-scoped-style-XXXXXX`，而该 class 只存在于本组件的根元素上，因此样式不会泄漏到其他组件。

> **建议：** 在组件中尽量使用 `.--this` 来限定样式作用域，避免全局污染。

---

## 八、Loader 注入的辅助方法

每个通过 Vue2Loader 加载的组件，其 `methods` 中会自动注入三个辅助方法：

| 方法                    | 签名                                  | 说明                           |
|-----------------------|-------------------------------------|------------------------------|
| `loaderHref()`        | `→ string`                          | 返回当前 `.vue` 文件自身的完整 URL      |
| `loaderUrl(url)`      | `(relativeUrl) → string`            | 将相对于组件的 URL 解析为完整绝对 URL      |
| `loaderResource(url)` | `(relativeUrl) → Promise<Response>` | 加载相对于组件的资源，返回 fetch Response |

### 使用场景

当组件需要加载与自身同目录下的静态资源（如 JSON、文本文件）时，用 `loaderUrl` 才能拿到正确路径：

```javascript
export default {
    name: 'DataPanel',
    data() {
        return {content: ''}
    },
    mounted() {
        // ✅ 正确：使用 loaderUrl 解析相对于组件的路径
        var url = this.loaderUrl('./data.json');
        fetch(url).then(r => r.json()).then(d => {
            this.content = d;
        });

        // ❌ 错误：直接写相对路径，会相对于 HTML 页面解析
        // fetch('./data.json')  // 这里的 . 是 HTML 所在目录，不是组件目录
    }
}
```

`loaderResource` 是更简洁的写法，内部等价于 `fetch(this.loaderUrl(url))`，直接返回 `Response`：

```javascript
export default {
    name: 'ReadmePanel',
    data() {
        return {readmeText: ''}
    },
    mounted() {
        // 使用 loaderResource 直接加载相对于当前组件的文本资源
        this.loaderResource('./README.md')
            .then(function (resp) {
                return resp.text()
            })
            .then(function (text) {
                this.readmeText = text;
            }.bind(this));
    }
}
```

> **提示：** `loaderResource` 内部调用的是已被 Vue2Loader 代理的 `window.fetch`，因此在 `file://` 协议下也能正常加载资源（会自动走
> JSONP / iframe 降级链），无需额外处理。

---

## 九、本地文件协议（`file://`）支持

浏览器安全限制下，`file://` 协议无法使用 XHR / fetch 加载本地文件。Vue2Loader 通过**链式降级**策略解决这个问题：

### 9.1 资源加载链

`fetchUrl` 按以下顺序依次尝试，任一成功即停止：

```
fetch → XMLHttpRequest → axios → JSONP(.jsonp.js) → iframe(.iframe.txt) → File System API
```

### 9.2 JSONP 方案

将原始文件转换为 `.jsonp.js` 后缀文件，内容为：

```javascript
jsonp_callback({"payload": "文件内容...", "path": "/xxx/file.vue", "name": "file.vue"})
```

加载器会动态创建 `<script>` 标签加载该文件，通过全局 `jsonp_callback` 函数接收内容。

### 9.3 iframe 方案

将原始文件复制为 `.iframe.txt` 后缀，通过创建隐藏 `<iframe>` 加载，从 `iframe.contentDocument.body pre` 中读取文本。

### 9.4 File System API 方案

使用浏览器 `showDirectoryPicker()` API，让用户手动选择项目目录，然后通过 File System Access API 直接读取文件内容。加载器会弹出提示引导用户操作。

### 9.5 Vue2Converter 转换工具

`vue2-converter.js` 是配套的批量转换工具，用于将项目文件批量生成 `.jsonp.js` 和 `.iframe.txt` 备份文件。

**使用方式（convertor.html）：**

1. 在浏览器中打开 `convertor/convertor.html`
2. 点击「加载项目文件」，选择项目根目录
3. 点击「开始转换」，为每个文件生成 `.jsonp.js` 和 `.iframe.txt`
4. 转换完成后，项目即可在 `file://` 协议下正常运行

**Vue2Converter API：**

| 方法                                                  | 说明                               |
|-----------------------------------------------------|----------------------------------|
| `Vue2Converter.getProjectFiles()`                   | 弹出目录选择器，扫描并返回文件列表                |
| `Vue2Converter.convertFiles(files, logger)`         | 批量生成 `.jsonp.js` 和 `.iframe.txt` |
| `Vue2Converter.removeGeneratedFiles(files, logger)` | 批量删除已生成的辅助文件                     |

> **建议：** 开发阶段使用 HTTP 服务器；发布为本地静态文件时，先用 Vue2Converter 转换，或直接使用 `convertor.html` 工具。

---

## 十、完整实战案例

以下是一个包含组件、混入、全局数据、动画初始化的完整示例，参考 spec 站点的真实用法：

### 10.1 项目结构

```
spec/
├── index.html                   ← 入口 HTML
├── assets/
│   ├── app.css                  ← 全局样式
│   ├── data.js                  ← 全局数据（window.$spec）
│   ├── state.js                 ← 全局状态（window.$specState）
│   └── render-utils.js          ← 渲染工具函数
├── components/
│   ├── app.vue                  ← 根组件
│   ├── AppNav.vue               ← 顶部导航
│   ├── SideNav.vue              ← 侧边目录
│   ├── ChapterSection.vue       ← 章节容器（动态加载子章节）
│   ├── AppFooter.vue
│   └── chapters/
│       ├── Ch01Overview.vue
│       ├── Ch02Design.vue
│       └── ...
├── lib/
│   ├── vue/vue-2.js
│   └── element-ui/...
└── vue2-loader/
    └── loader/Vue2Loader.js
```

### 10.2 index.html

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>技术文档</title>
    <link rel="stylesheet" href="./assets/app.css">

    <!-- 第三方库 -->
    <script src="./lib/vue/vue-2.js"></script>
    <script src="./lib/element-ui/element-ui-2.15.10.js"></script>
    <link rel="stylesheet" href="./lib/element-ui/element-ui-2.15.10.css"/>

    <!-- Vue2Loader -->
    <script src="./vue2-loader/loader/Vue2Loader.js"></script>
</head>
<body>
<div id="app"></div>

<!-- 全局数据（在 Vue2Loader 之前或之后均可） -->
<script src="./assets/data.js"></script>
<script src="./assets/state.js"></script>
<script src="./assets/render-utils.js"></script>

<!-- 启动应用 -->
<script>
    Vue2Loader.createVue('./components/app.vue', 'app').then(function (app) {
        window.app = app;
    });
</script>
</body>
</html>
```

### 10.3 components/app.vue（根组件）

```html

<template>
    <div>
        <AppNav/>
        <div class="layout">
            <SideNav/>
            <main class="main-content">
                <ChapterSection
                        v-for="ch in spec.chapters"
                        :key="ch.id"
                        :chapter="ch"
                />
                <AppFooter/>
            </main>
        </div>
    </div>
</template>

<header>
    <title>技术全景文档</title>
</header>

<script>
    export default {
        name: 'App',
        components: {
            AppNav: './AppNav.vue',
            SideNav: './SideNav.vue',
            ChapterSection: './ChapterSection.vue',
            AppFooter: './AppFooter.vue'
        },
        data: function () {
            return {
                spec: window.$spec,
                state: window.$specState
            };
        },
        mounted: function () {
            window.addEventListener('scroll', this.onScroll, {passive: true});
        },
        methods: {
            onScroll: function () {
                // 滚动处理逻辑...
            }
        }
    };
</script>
```

### 10.4 components/ChapterSection.vue（动态子组件加载）

```html

<template>
    <section :id="chapter.id" class="chapter">
        <h2>{{ chapter.title }}</h2>
        <component :is="chapterComponent"/>
    </section>
</template>

<script>
    var chapterMap = {
        'ch01': 'Ch01Overview',
        'ch02': 'Ch02Design'
        // ...
    };

    export default {
        name: 'ChapterSection',
        props: {
            chapter: {type: Object, required: true}
        },
        components: {
            Ch01Overview: './chapters/Ch01Overview.vue',
            Ch02Design: './chapters/Ch02Design.vue'
            // ...
        },
        computed: {
            chapterComponent: function () {
                return chapterMap[this.chapter.id] || 'div';
            }
        }
    };
</script>
```

> **技巧：** 利用 `<component :is="...">` 配合 `components` 中的 URL 注册，可以实现**按需懒加载**章节组件——只有当
`chapterComponent` 计算值变化时，对应的 `.vue` 文件才会被加载。

---

## 十一、`window.fetch` 代理

Vue2Loader 加载时会**自动替换 `window.fetch`** 为 `Vue2Loader.resourceFetch`，以便在 `file://` 协议下也能正常加载资源：

```javascript
// Vue2Loader.js 内部
window.fetch = Vue2Loader.resourceFetch;
```

`resourceFetch` 在 `file://` 协议下会走 JSONP → iframe → File System API 的降级链；在 HTTP 协议下则直接透传给原始 `fetch`
，对业务代码完全透明。

若需使用原始 fetch，可通过 `Vue2Loader.originFetch` 访问。

---

## 十二、注意事项与限制

### 语法限制

| 限制                    | 说明                                                  |
|-----------------------|-----------------------------------------------------|
| ❌ 不支持 `import`        | 不能在 `.vue` 的 `<script>` 中使用 `import` 语句             |
| ❌ 只能 `export default` | 不能 `export` 具名导出，每个文件只能有一个 `export default {}`      |
| ⚠️ 标签独占一行             | `<template>`、`<script>` 等开始/结束标签必须独占一行，不能与内容混行      |
| ⚠️ `scoped` 不真正生效     | `<style scoped>` 的 `scoped` 属性无实际效果，需用 `.--this` 替代 |

### 路径注意

- `components` / `mixins` / `directives` / `objects` 中的 URL 是**相对于当前 `.vue` 文件**的
- `createVue` 的 `url` 参数是**相对于 HTML 页面**的
- 在 `methods` 中加载相对于组件的资源，必须使用 `this.loaderUrl()` 而非直接写相对路径

### 性能注意

- 每个 `.vue` 文件都会触发一次 HTTP 请求，组件数量过多时会影响加载速度
- `fetchUrl` 有 30 秒缓存机制（按 30 秒时间窗口去重），但无持久化缓存
- 建议合理拆分组件，避免过深的组件嵌套层级

### 浏览器兼容

- 依赖 `Promise`、`XMLHttpRequest`、`DOMParser`、`URL` 等现代 API
- File System API（`showDirectoryPicker`）仅在 Chromium 内核浏览器中可用
- 建议在 Chrome / Edge / Firefox 最新版本中使用

---

## 十三、API 速查表

```
Vue2Loader.createVue(url, domId?)         → Promise<Vue>
Vue2Loader.loadVueOptions(url)            → Promise<Object>
Vue2Loader.loadVueComponent(url)          → Promise<Function>
Vue2Loader.registryVueComponent(url, name?) → Promise<Function>
Vue2Loader.registryVueDirective(url, name?) → Promise<Function>
Vue2Loader.loadObject(url)                → Promise<Object>
Vue2Loader.fetchUrl(url)                  → Promise<string>
Vue2Loader.appendHeader(headerHtml)       → void
Vue2Loader.parseVueTemplate(html)         → Object
Vue2Loader.notify(content, level?)        → void
Vue2Loader.copyToClipboard(text)          → void

组件内注入方法：
this.loaderHref()                         → string（当前组件 URL）
this.loaderUrl(relativeUrl)               → string（绝对路径）
this.loaderResource(relativeUrl)          → Promise<Response>
```

---

## 十四、与 Vue CLI / Webpack 的对比

| 特性                  | Vue CLI / Webpack | Vue2Loader                      |
|---------------------|-------------------|---------------------------------|
| 构建步骤                | 需要                | 不需要                             |
| `import` / `export` | 完整支持              | 不支持 `import`，仅 `export default` |
| `.vue` 文件           | 完整支持              | 支持（运行时解析）                       |
| `scoped` 样式         | 真正 scoped（属性选择器）  | `.--this` 模拟（class 替换）          |
| 热更新（HMR）            | 支持                | 不支持                             |
| 单文件组件嵌套             | 支持                | 支持（递归 URL 加载）                   |
| 部署复杂度               | 需构建产物             | 直接部署源码                          |
| 适用场景                | 生产级应用             | 内部工具、文档站、原型                     |

---

## 十五、迁移到 Vue CLI / Webpack

当项目规模增长到需要热更新、代码分割、Tree Shaking 等能力时，可以将 Vue2Loader 项目迁移到标准的 Vue CLI（webpack）工程。两者的
`.vue` 文件结构高度相似，迁移成本较低，核心工作集中在**依赖声明方式**和**资源加载方式**的改造上。

### 15.1 差异点总览

| 差异点                   | Vue2Loader 写法                               | Vue CLI 写法                                              |
|-----------------------|---------------------------------------------|---------------------------------------------------------|
| 组件引入                  | `components: { Comp: './Comp.vue' }`        | `import Comp from './Comp.vue'`                         |
| 混入引入                  | `mixins: ['./mixin.js']`                    | `import mixin from './mixin.js'`                        |
| 指令引入                  | `directives: { show: './show.js' }`         | `import show from './show.js'`                          |
| 工具对象挂载                | `objects: { rsa: './rsa.js' }` → `this.rsa` | `import rsa from './rsa.js'` 直接使用，或手动挂到 `Vue.prototype` |
| `import` 语句           | ❌ 不允许                                       | ✅ 完整支持                                                  |
| `export default`      | 唯一导出方式                                      | 支持，同时支持具名 `export`                                      |
| `<style scoped>`      | `scoped` 属性无效，需用 `.--this`                  | 真正 scoped，可直接使用                                         |
| `.--this` 选择器         | 仿 scoped 核心机制                               | 不需要，可全部替换为普通选择器                                         |
| `<header>` 块          | 注入到 `document.head`                         | 不存在此机制，改用 `public/index.html` 或 `vue-meta` 插件           |
| `loaderHref()`        | 返回当前 `.vue` 文件的 URL                         | 不需要，使用 `import` 或 `require()` 获取资源路径                    |
| `loaderUrl(url)`      | 解析相对于组件的资源 URL                              | 使用 `require(url)` 或 `import` 静态引入                       |
| `loaderResource(url)` | 加载相对于组件的资源                                  | 使用 `import()` 动态导入，或 `require()` + `fetch`              |
| 入口文件                  | `index.html` + `Vue2Loader.createVue()`     | `main.js` + `new Vue({ render: h => h(App) })`          |
| 第三方库                  | HTML 中 `<script>` 全局引入                      | `npm install` + `import` 按需引入                           |
| 全局数据                  | `window.$spec` 等全局变量                        | `Vue.prototype.$spec` 或 Vuex / provide-inject           |

### 15.2 迁移步骤

#### 第一步：初始化 Vue CLI 工程

```bash
vue create my-project
# 选择 Vue 2 预设
```

将原 `components/` 目录整体复制到 `src/` 下，保持目录结构不变。

#### 第二步：改造入口

**迁移前（Vue2Loader）：**

```html
<!-- index.html -->
<script src="./lib/vue/vue-2.js"></script>
<script src="./vue2-loader/loader/Vue2Loader.js"></script>
<script>
    Vue2Loader.createVue('./components/app.vue', 'app').then(function (app) {
        window.app = app;
    });
</script>
```

**迁移后（Vue CLI）：**

```javascript
// src/main.js
import Vue from 'vue';
import App from './components/app.vue';

Vue.config.productionTip = false;

new Vue({
    render: h => h(App)
}).$mount('#app');
```

`public/index.html` 中只需保留 `<div id="app"></div>` 挂载点，移除所有手动引入的 `<script>` 标签。

#### 第三步：改造组件依赖声明（components）

这是迁移工作量最大的部分，需要将每个 `.vue` 文件中的 URL 字符串替换为 `import` 语句。

**迁移前（Vue2Loader）：**

```html

<script>
    export default {
        name: 'App',
        components: {
            AppNav: './AppNav.vue',
            SideNav: './SideNav.vue',
            ChapterSection: './ChapterSection.vue',
            AppFooter: './AppFooter.vue'
        },
        // ...
    }
</script>
```

**迁移后（Vue CLI）：**

```html

<script>
    import AppNav from './AppNav.vue';
    import SideNav from './SideNav.vue';
    import ChapterSection from './ChapterSection.vue';
    import AppFooter from './AppFooter.vue';

    export default {
        name: 'App',
        components: {
            AppNav,
            SideNav,
            ChapterSection,
            AppFooter
        },
        // ...
    }
</script>
```

> **批量替换技巧：** 可用正则 `/(\w+):\s*'([^']+\.vue)'` 匹配，替换为 `import $1 from '$2';` 并修改 components 块为简写形式。

#### 第四步：改造混入（mixins）

**迁移前：**

```javascript
mixins: ['./mixins/logger.js', './mixins/validator.js']
```

**迁移后：**

```javascript
import logger from './mixins/logger.js';
import validator from './mixins/validator.js';

export default {
    mixins: [logger, validator],
    // ...
}
```

#### 第五步：改造指令（directives）

**迁移前：**

```javascript
directives: {
    focus: './directives/focus.js'
}
```

**迁移后：**

```javascript
import focus from './directives/focus.js';

export default {
    directives: {
        focus   // 局部注册
    },
    // ...
}

// 或者在 main.js 中全局注册：
// import focus from './directives/focus.js';
// Vue.directive('focus', focus);
```

#### 第六步：改造对象挂载（objects）

`objects` 是 Vue2Loader 特有的机制，将工具对象挂载到 `Vue.prototype`，迁移后有两种替代方案：

**方案 A：直接 import 使用（推荐）**

```javascript
// 迁移前
objects: {
    rsa: './utils/rsa.js'
}
// 在方法中：this.rsa.encrypt(text)

// 迁移后
import rsa from './utils/rsa.js';
// 在方法中直接：rsa.encrypt(text)
```

**方案 B：保留 `this.xxx` 访问方式**

```javascript
// main.js 中手动挂载
import rsa from './utils/rsa.js';

Vue.prototype.$rsa = rsa;

// 组件中仍然可以 this.$rsa.encrypt(text)
```

#### 第七步：改造样式（`.--this` → `scoped`）

Vue CLI 的 `<style scoped>` 是真正的 scoped（通过 data 属性选择器实现），迁移后可以：

1. 给 `<style>` 加上 `scoped` 属性
2. 将所有 `.--this` 选择器替换为普通选择器（因为 scoped 已经保证了隔离性）

**迁移前：**

```html

<style>
    .app {
        color: #333;
    }

    .--this span {
        color: coral;
    }

    .--this {
        background: #f5f5f5;
    }
</style>
```

**迁移后：**

```html

<style scoped>
    .app {
        color: #333;
    }

    span {
        color: coral;
    }

    /* scoped 已保证不影响其他组件 */
    .app {
        background: #f5f5f5;
    }

    /* 直接用根元素 class 代替 .--this */
</style>
```

#### 第八步：改造 `<header>` 块

Vue2Loader 的 `<header>` 块用于动态注入 `<title>` 等内容，迁移后改用以下方式：

**方案 A：直接写在 `public/index.html`（适合单页应用）**

```html
<!-- public/index.html -->
<head>
    <title>我的应用</title>
</head>
```

**方案 B：使用 `vue-meta` 插件（适合需要动态修改 title 的场景）**

```bash
npm install vue-meta@2
```

```javascript
// main.js
import VueMeta from 'vue-meta';

Vue.use(VueMeta);

// 组件中
export default {
    metaInfo: {
        title: '我的页面'
    }
}
```

#### 第九步：改造资源加载方法（loaderUrl / loaderResource）

`loaderHref` / `loaderUrl` / `loaderResource` 是 Vue2Loader 注入的辅助方法，在 webpack 中无意义，需要替换为 webpack
的资源引入方式。

**迁移前：**

```javascript
mounted()
{
    // 加载相对于组件的 JSON 文件
    this.loaderResource('./data.json')
        .then(r => r.json())
        .then(d => {
            this.data = d;
        });
}
```

**迁移后（方案 A：静态引入，推荐）：**

```javascript
// webpack 会将 JSON 打包进产物
import dataJson from './data.json';

export default {
    data() {
        return {data: dataJson};
    }
}
```

**迁移后（方案 B：动态加载，适合大文件）：**

```javascript
// 将文件放到 public/ 目录，通过绝对路径访问
mounted()
{
    fetch('/data/data.json')
        .then(r => r.json())
        .then(d => {
            this.data = d;
        });
}
```

#### 第十步：改造全局变量

Vue2Loader 项目中常用 `window.$spec`、`window.$specState` 等全局变量传递数据，迁移后建议改为更规范的方式：

| 原写法                         | 迁移方案                                             |
|-----------------------------|--------------------------------------------------|
| `window.$spec = {...}`      | `Vue.prototype.$spec = {...}` 或 `provide/inject` |
| `window.$specState = {...}` | Vuex 状态管理                                        |
| `window.app = vue实例`        | `this` 或 `$root` 访问根实例                           |

### 15.3 完整迁移对照示例

以下展示一个典型组件的迁移前后完整对比：

**迁移前（Vue2Loader）— ChapterSection.vue**

```html

<template>
    <section :id="chapter.id" class="chapter">
        <h2>{{ chapter.title }}</h2>
        <component :is="chapterComponent"/>
    </section>
</template>

<script>
    var chapterMap = {
        'ch01': 'Ch01Overview',
        'ch02': 'Ch02Design'
    };

    export default {
        name: 'ChapterSection',
        props: {
            chapter: {type: Object, required: true}
        },
        components: {
            Ch01Overview: './chapters/Ch01Overview.vue',
            Ch02Design: './chapters/Ch02Design.vue'
        },
        computed: {
            chapterComponent: function () {
                return chapterMap[this.chapter.id] || 'div';
            }
        }
    };
</script>

<style>
    .--this {
        padding: 16px;
    }

    .--this h2 {
        color: #333;
    }
</style>
```

**迁移后（Vue CLI）— ChapterSection.vue**

```html

<template>
    <section :id="chapter.id" class="chapter">
        <h2>{{ chapter.title }}</h2>
        <component :is="chapterComponent"/>
    </section>
</template>

<script>
    import Ch01Overview from './chapters/Ch01Overview.vue';
    import Ch02Design from './chapters/Ch02Design.vue';

    const chapterMap = {
        'ch01': 'Ch01Overview',
        'ch02': 'Ch02Design'
    };

    export default {
        name: 'ChapterSection',
        props: {
            chapter: {type: Object, required: true}
        },
        components: {
            Ch01Overview,
            Ch02Design
        },
        computed: {
            chapterComponent() {
                return chapterMap[this.chapter.id] || 'div';
            }
        }
    };
</script>

<style scoped>
    .chapter {
        padding: 16px;
    }

    /* .--this → 直接用根元素 class */
    h2 {
        color: #333;
    }

    /* scoped 保证不影响其他组件 */
</style>
```

### 15.4 迁移检查清单

完成迁移后，逐项确认以下内容：

- [ ] 所有 `.vue` 文件中的 `components` URL 字符串已替换为 `import` 语句
- [ ] 所有 `mixins` URL 字符串已替换为 `import` 语句
- [ ] 所有 `directives` URL 字符串已替换为 `import` 语句
- [ ] 所有 `objects` URL 字符串已替换为 `import` 或 `Vue.prototype` 挂载
- [ ] 所有 `.--this` 选择器已替换为普通选择器，并加上 `scoped` 属性
- [ ] 所有 `<header>` 块已移除，内容迁移到 `public/index.html` 或 `vue-meta`
- [ ] 所有 `loaderHref()` / `loaderUrl()` / `loaderResource()` 调用已替换
- [ ] 所有 `window.$xxx` 全局变量已改为 `Vue.prototype` / Vuex / provide-inject
- [ ] `index.html` 入口改为 Vue CLI 标准模板，移除 Vue2Loader.js 引用
- [ ] `main.js` 使用 `new Vue({ render: h => h(App) })` 启动
- [ ] 第三方库从 HTML `<script>` 改为 `npm install` + `import`
- [ ] `npm run serve` 开发服务器正常启动，无报错
- [ ] `npm run build` 构建产物可正常部署

### 15.5 迁移收益

| 能力           | Vue2Loader | Vue CLI                     |
|--------------|------------|-----------------------------|
| 开发热更新        | ❌ 需手动刷新    | ✅ HMR 即时生效                  |
| 代码压缩         | ❌ 源码部署     | ✅ 自动压缩混淆                    |
| Tree Shaking | ❌ 全量加载     | ✅ 按需打包                      |
| 代码分割         | ❌ 不支持      | ✅ 路由懒加载                     |
| CSS 预处理      | ❌ 仅原生 CSS  | ✅ SCSS / LESS / Stylus      |
| 单元测试         | ❌ 难以配置     | ✅ Jest / Mocha 集成           |
| TypeScript   | ❌ 不支持      | ✅ 完整支持                      |
| 生态工具         | ❌ 无        | ✅ ESLint / Prettier / Husky |

---

## 附录、资源附件

以下是 Vue2Loader 的完整资源文件，点击链接可直接查看或下载。

### 目录结构

```
vue2-loader/
├── convertor/                          # 本地 file:// 协议转换工具
│   ├── convertor.html                  # 转换工具页面
│   └── vue2-converter.js               # 转换逻辑实现
├── loader/                             # 核心加载器
│   ├── Vue2Loader.js                   # 核心库文件
│   ├── vue@2_dist_vue.js               # Vue 2 运行时
│   └── test/                           # 测试用例
│       ├── vue2-loader.html            # 测试入口页面
│       ├── components/
│       │   ├── app.vue                 # 根组件
│       │   ├── test.vue                # 测试组件
│       │   └── comp/
│       │       ├── comp.vue            # 子组件
│       │       └── reso/
│       │           └── reso.vue        # 孙组件
│       └── mixins/
│           └── mixin.js                # 测试混入
└── readme.md                           # 简要说明
```

### 核心文件

| 文件 | 说明 |
| --- | --- |
| [Vue2Loader.js](../docs-site/vue2-loader/loader/Vue2Loader.js) | 核心库，负责 `.vue` 文件解析、组件加载与资源降级获取 |
| [vue@2_dist_vue.js](../docs-site/vue2-loader/loader/vue@2_dist_vue.js) | Vue 2 运行时（完整版，含编译器） |

### 转换工具

| 文件 | 说明 |
| --- | --- |
| [convertor.html](../docs-site/vue2-loader/convertor/convertor.html) | 本地转换工具页面，用于生成 JSONP/iframe 格式文件以支持 `file://` 协议 |
| [vue2-converter.js](../docs-site/vue2-loader/convertor/vue2-converter.js) | 转换工具核心逻辑 |

### 测试用例

| 文件 | 说明 |
| --- | --- |
| [vue2-loader.html](../docs-site/vue2-loader/loader/test/vue2-loader.html) | 测试入口页面 |
| [app.vue](../docs-site/vue2-loader/loader/test/components/app.vue) | 根组件，演示组件嵌套与混入 |
| [test.vue](../docs-site/vue2-loader/loader/test/components/test.vue) | 测试组件 |
| [comp.vue](../docs-site/vue2-loader/loader/test/components/comp/comp.vue) | 子组件 |
| [reso.vue](../docs-site/vue2-loader/loader/test/components/comp/reso/reso.vue) | 孙组件，演示多层嵌套 |
| [mixin.js](../docs-site/vue2-loader/loader/test/mixins/mixin.js) | 测试混入文件 |
