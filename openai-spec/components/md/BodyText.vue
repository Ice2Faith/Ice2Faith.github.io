<template>
    <p class="body" :style="size ? 'font-size:' + size + ';' : ''"><slot></slot></p>
</template>
<script>
    export default {
        name: 'BodyText',
        props: {
            size: { type: String, default: '' }
        }
    };
</script>
