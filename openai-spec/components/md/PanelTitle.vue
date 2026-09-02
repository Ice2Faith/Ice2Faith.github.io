<template>
    <div class="panel-title">{{ title }}</div>
</template>
<script>
    export default {
        name: 'PanelTitle',
        props: {
            title: { type: String, required: true }
        }
    };
</script>
