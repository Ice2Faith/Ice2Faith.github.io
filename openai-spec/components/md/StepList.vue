<template>
    <div class="step-list" :style="style"><slot></slot></div>
</template>
<script>
    export default {
        name: 'StepList',
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
