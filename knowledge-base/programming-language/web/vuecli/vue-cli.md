# vue-cli 安装

---

## 前提依赖
- 请先安装 nodejs
- 参考：../nodejs/nodejs.md

## 安装
- 官方教程
```shell script
https://cli.vuejs.org/zh/guide/installation.html
```
- 确认nodejs安装成功
```shell script
node -v
npm -v
```
- 安装vue-cli
```shell script
npm install -g @vue/cli
```
- 验证安装
```shell script
vue -v
```

## 创建vue项目
- 初始化vue项目
```shell script
vue create hello
```
- 这里我按照惯用开发配置进行自定义项目为例
- 习惯vue项目开发的应该就不用说了
    - 上下键切换选项
    - 空格键选择或取消
    - 回车确认
- 自定义初始化
```shell script
Vue CLI v5.0.8
? Please pick a preset:
  Default ([Vue 3] babel, eslint)
  Default ([Vue 2] babel, eslint)
> Manually select features
```
- 选择组件
    - 选择 router,vuex,babel,eslint,css
```shell script
Vue CLI v5.0.8
? Please pick a preset: Manually select features
? Check the features needed for your project: (Press <space> to select, <a> to toggle all, <i> to invert selection, and
<enter> to proceed)
 (*) Babel
 ( ) TypeScript
 ( ) Progressive Web App (PWA) Support
 (*) Router
 (*) Vuex
>(*) CSS Pre-processors
 (*) Linter / Formatter
 ( ) Unit Testing
 ( ) E2E Testing
```
- 使用vue3
```shell script
Vue CLI v5.0.8
? Please pick a preset: Manually select features
? Check the features needed for your project: Babel, Router, Vuex, CSS Pre-processors, Linter
? Choose a version of Vue.js that you want to start the project with (Use arrow keys)
> 3.x
  2.x
```
- 使用hash路由
```shell script
Vue CLI v5.0.8
? Please pick a preset: Manually select features
? Check the features needed for your project: Babel, Router, Vuex, CSS Pre-processors, Linter
? Choose a version of Vue.js that you want to start the project with 3.x
? Use history mode for router? (Requires proper server setup for index fallback in production) (Y/n) n
```
- 使用sass
```shell script
? Pick a CSS pre-processor (PostCSS, Autoprefixer and CSS Modules are supported by default): (Use arrow keys)
> Sass/SCSS (with dart-sass)
  Less
  Stylus
```
- 使用eslint+prettier
```shell script
? Pick a linter / formatter config:
  ESLint with error prevention only
  ESLint + Airbnb config
  ESLint + Standard config
> ESLint + Prettier
```
- 提交保存时自动进行eslint fix
```shell script
? Pick additional lint features: (Press <space> to select, <a> to toggle all, <i> to invert selection, and <enter> to
proceed)
 (*) Lint on save
>(*) Lint and fix on commit
```
- 配置全都放到package.json中
```shell script
? Where do you prefer placing config for Babel, ESLint, etc.?
  In dedicated config files
> In package.json
```
- 根据自己习惯决定是否这个作为一个预设配置
```shell script
? Save this as a preset for future projects? (y/N) n
```
- 等待下载依赖完成

## 运行vue项目
- 进入项目
```shell script
cd hello
```
- 检查安装依赖
```shell script
npm install
```
- 运行
```shell script
npm run serve
```
- 会看到运行提示
```shell script
 DONE  Compiled successfully in 6032ms                                                                          22:42:56


  App running at:
  - Local:   http://localhost:8080/
  - Network: http://192.168.1.22:8080/

  Note that the development build is not optimized.
  To create a production build, run npm run build.
```
- 默认会打开浏览器
    - 没有打开的话，自己浏览器打开查看
```shell script
http://localhost:8080/
```
- 看到vue项目的简介信息即可
- 退出服务
```shell script
Ctrl+C
```