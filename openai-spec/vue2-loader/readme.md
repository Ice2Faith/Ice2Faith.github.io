# Vue2Loader

- help use vue2 in multi-page-application website
- this could improve coding style & structure
- bring out simplify , purify vue code like vue-cli
- but also, it has some restrict with it
- such as, could not use 'import' and 'export' segments for process other modules
- only support use 'export default' to  export default vue component(or instance)
- so that, import other modules must by global '&lt;script&gt;' in html

---

## test.html

- this is a ***test.html*** file

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>vue2</title>
	<!-- 引入VUE -->
    <script src="../vue@2_dist_vue.js"></script>
    <script src="../Vue2Loader.js"></script>
</head>
<body>
<div id="app">
</div>
</body>
<script>

    Vue2Loader.createVue('./components/app.vue','#app')

</script>
<style>

</style>
</html>
```

## app.vue

- this is a ***app.vue*** file

```html
<template>
    <div class="app">
        {{message}}
        <span>world</span>
        <comp></comp>
        <hr/>
        <reso></reso>
    </div>
</template>

<header>
    <title>加油</title>
</header>

<script>
    export default {
        name: "test",
        title: '测试页面',
        components:{
            comp: './comp/comp.vue',
            reso: './comp/reso/reso.vue'
        },
        mixins:['../mixins/mixin.js'],
        data(){
            return {
                message: 'hello'
            }
        },
        created(){
            this.alertHello()
        }
    }
</script>

<style scoped>
    .app{
        color: blue;
    }
    .--this{
        background: lightseagreen;
    }
    .--this span{
        color: coral;
    }
    span{
        color: cyan;
    }
</style>
```

---

- now, you got an vue page ***test.html***,and could be view it in browser
- but also, if you want view page in local file, 
- you must use ***vue2-converter.js*** to convert as local ***cors-origin*** support format(jsonp)
- or direct use ***convertor.html*** to complete this work.

## more

- more information cloud to view comments doc in ***Vue2Loader.js***