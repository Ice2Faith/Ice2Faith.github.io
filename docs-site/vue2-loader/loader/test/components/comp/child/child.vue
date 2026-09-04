<template>
  <div>
    {{message}}
    <span>is xxx!</span>
    <hr/>
    <next></next>
  </div>
</template>


<script>
export default {
  components:{
    next: '../comp.vue'
  },
  data(){
    return {
      message: 'xxx',
      timer:null
    }
  },
  mounted(){
    this.timer=setInterval(()=>{
      this.message=new Date().getTime()+'///'
    },1000)
  },
  destroyed(){
    clearInterval(this.timer)
  }
}
</script>


