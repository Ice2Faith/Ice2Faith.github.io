<template>
    <div class="panel">
        <div v-if="title" class="panel-title">{{ title }}</div>
        <slot></slot>
    </div>
</template>
<script>
    export default {
        name: 'Panel',
        props: {
            title: { type: String, default: '' }
        }
    };
</script>
