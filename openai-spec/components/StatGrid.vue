<template>
    <section class="stat-section reveal">
        <div class="stat-grid">
            <div class="stat-item" v-for="(s, i) in spec.stats" :key="i" :style="{ '--sc': s.color }">
                <span class="stat-count" :data-target="s.count">0</span>
                <span class="stat-label">{{ s.label }}</span>
            </div>
        </div>
    </section>
</template>

<script>
    export default {
        name: 'StatGrid',
        computed: {
            spec: function () {
                return window.$spec;
            }
        }
    };
</script>
