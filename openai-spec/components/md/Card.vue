<template>
    <div class="card" :style="{'--c': color}">
        <span v-if="idx" class="idx">{{ idx }}</span>
        <h3>{{ title }}</h3>
        <div v-if="tagline" class="tagline">{{ tagline }}</div>
        <slot></slot>
    </div>
</template>
<script>
    export default {
        name: 'Card',
        props: {
            color: { type: String, default: '#e8590c' },
            idx: { type: String, default: '' },
            title: { type: String, default: '' },
            tagline: { type: String, default: '' }
        }
    };
</script>
