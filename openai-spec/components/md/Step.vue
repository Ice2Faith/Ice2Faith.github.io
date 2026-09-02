<template>
    <div class="step">
        <div class="no"></div>
        <div class="bd">
            <h4 v-if="title" v-html="title"></h4>
            <slot></slot>
        </div>
    </div>
</template>
<script>
    export default {
        name: 'Step',
        props: {
            title: { type: String, default: '' }
        }
    };
</script>
