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


