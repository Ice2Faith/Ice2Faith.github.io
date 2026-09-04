<template>
  <div class="comp">
    {{message}}
    <span>is now!</span>
  </div>
</template>


<script>
export default {
  name: "comp",
  data(){
    return {
      message: 'xxx',
      timer:null
    }
  },
  mounted(){
    this.timer=setInterval(()=>{
      this.message=new Date()+''
    },1000)
  },
  destroyed(){
    clearInterval(this.timer)
  }
}
</script>

<style>
.comp{
  color: red;
}

.--this span{
  color: lawngreen;
}
</style>

