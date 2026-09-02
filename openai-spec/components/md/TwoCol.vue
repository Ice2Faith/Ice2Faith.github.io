<template>
    <div class="two-col" :style="style">
        <div><slot name="left"></slot></div>
        <div><slot name="right"></slot></div>
    </div>
</template>
<script>
    export default {
        name: 'TwoCol',
        props: {
            marginTop: { type: String, default: '' }
        },
        computed: {
            style: function () {
                return this.marginTop ? 'margin-top:' + this.marginTop + ';' : '';
            }
        }
    };
</script>
