# WEB 资源的 CDN 引入方式

---

## 简介
- 一般来说，目前的前端项目都是使用打包/构建工具进行开发
- 然而，我们有时候又不想那么麻烦的开一个构建项目
- 而是只需要实现一些简单的单页应用
- 比如，使用VUE来实现一些简单的单页应用
- 那么，此时，直接使用静态进入的方式就是比较适合的

## 静态引入
- 静态引入，也就是不借助打包/构建工具的方式
- 引入webpack等的第三方依赖主键
- 也就是 min.js 等引入方式
- 目前的方式主要有两种
- 第一种，将资源下载到本地，使用相对路径引入
- 第二种，直接使用托管的公共CDN源

## CDN引入
- 目前的资源托管，主要有两个
```shell script
https://unpkg.com/
https://cdn.jsdelivr.net/npm/
```
- 不过，两者都是国外服务器
- 在国内使用体验并不好，容易访问不到资源
- 因此可以使用国内镜像CDN
```shell script
https://unpkg.zhimg.com/
```
- 替换规则如下
```shell script
https://unpkg.com/...
-->
https://unpkg.zhimg.com/...

https://cdn.jsdelivr.net/npm/...
-->
https://unpkg.zhimg.com/...
```
- 下面举例说明
- vue2的CDN
```shell script
<script src="https://cdn.jsdelivr.net/npm/vue@2.7.14/dist/vue.js"></script>
-->
<script src="https://unpkg.zhimg.com/vue@2.7.14/dist/vue.js"></script>
```
- element-ui的CDN
```shell script
<link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
<script src="https://unpkg.com/element-ui/lib/index.js"></script>
-->
<link rel="stylesheet" href="https://unpkg.zhimg.com/element-ui/lib/theme-chalk/index.css">
<script src="https://unpkg.zhimg.com/element-ui/lib/index.js"></script>
```
- 其他资源
- 也可以按照如此方式尝试替换
- 不过，也不是任意资源都有镜像
- 这时候，就需要下载到本地
- 使用本地文件引入了

## 使用举例
- 下面，就以一个vue2和element-ui构建一个基本页面为例
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CDN静态引入</title>

    <!-- vue2 -->
    <script src="https://unpkg.zhimg.com/vue@2.7.14/dist/vue.js"></script>

    <!-- element-ui -->
    <!-- 引入样式 -->
    <link rel="stylesheet" href="https://unpkg.zhimg.com/element-ui/lib/theme-chalk/index.css">
    <!-- 引入组件库 -->
    <script src="https://unpkg.zhimg.com/element-ui/lib/index.js"></script>


</head>
<body>
<div id="app">
    <el-card :header="title" shadow="never">
        <el-input
                type="textarea"
                :rows="10"
                placeholder="在此输入JS表达式"
                v-model="formula">
        </el-input>
        <el-row :gutter="20" type="flex" justify="center">
            <el-button type="primary" @click="run">运行</el-button>
        </el-row>
        <el-input
                type="textarea"
                :rows="10"
                placeholder="在此输入JS表达式"
                v-model="result">
        </el-input>
    </el-card>
</div>
</body>
<script>
    window.app = new Vue({
        el: '#app',
        data() {
            return {
                title: 'JS表达式计算',
                formula: 'function add(a,b){\n' +
                    '  return a+b\n' +
                    '}\n' +
                    'add(1,2)',
                result: ''
            }
        },
        methods:{
            run(){
                let rs=eval(this.formula)
                this.result=JSON.stringify(rs,null,'    ')
            }
        }
    })
</script>
```

## CDN 搜索站
- bootcdn
- 国内访问良好
```shell script
https://www.bootcdn.cn/
```

## 常用CDN的引入
- VUE2
```html
<!-- vue2 -->
<script src="https://unpkg.zhimg.com/vue@2.7.14/dist/vue.js"></script>
```
- VUE3
```html
<!-- vue3 -->
<script src="https://unpkg.zhimg.com/vue@3.3.7/dist/vue.global.js"></script>
```
- element-ui for vue2
```html
<!-- element-ui -->
<!-- 引入样式 -->
<link rel="stylesheet" href="https://unpkg.zhimg.com/element-ui/lib/theme-chalk/index.css">
<!-- 引入组件库 -->
<script src="https://unpkg.zhimg.com/element-ui/lib/index.js"></script>
```
- vant2 for vue2
```html
<!-- vant2 -->
<!-- 引入样式 -->
<link rel="stylesheet" href="https://unpkg.zhimg.com/vant@2.12.54/lib/index.css">
<!-- 引入组件库 -->
<script src="https://unpkg.zhimg.com/vant@2.12.54/lib/vant.min.js"></script>
```
- vant4 for vue3
```html
<!-- vant4 -->
<!-- 引入样式 -->
<link rel="stylesheet" href="https://unpkg.zhimg.com/vant@4.7.3/lib/index.css">
<!-- 引入组件库 -->
<script src="https://unpkg.zhimg.com/vant@4.7.3/lib/vant.min.js"></script>
```
- three-js
```shell script
<!-- three-js -->
<script src="https://unpkg.com/three@0.158.0/build/three.min.js"></script>
```
- axios
```html
<!-- axios -->
<script src="https://unpkg.zhimg.com/axios@1.5.0/dist/axios.min.js"></script>
```
- jquery
```html
<!-- jquery -->
<script src="https://unpkg.zhimg.com/jquery@3.7.1/dist/jquery.min.js"></script>
```
- gsap
```html
<!-- jquery -->
<script src="https://cdn.bootcdn.net/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
```
