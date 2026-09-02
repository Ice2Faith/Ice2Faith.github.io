<template>
    <div class="callout" :class="{ quote: quote }" :style="{'--c': color}">
        <div v-if="title" class="co-title">{{ title }}</div>
        <slot></slot>
    </div>
</template>
<script>
    export default {
        name: 'Callout',
        props: {
            color: { type: String, default: '#0b7285' },
            title: { type: String, default: '' },
            quote: { type: Boolean, default: false }
        }
    };
</script>
