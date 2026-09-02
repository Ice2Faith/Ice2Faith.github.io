<template>
  <div>
    {{message}}
    <span>is ts!</span>
    <hr/>
    <child></child>
  </div>
</template>


<script>
export default {
  components:{
    child: '../child/child.vue'
  },
  data(){
    return {
      message: 'xxx',
      timer:null
    }
  },
  mounted(){
    this.timer=setInterval(()=>{
      this.message=new Date().getTime()+''
    },1000)
  },
  destroyed(){
    clearInterval(this.timer)
  }
}
</script>


