<template>
    <span class="tag" :class="typeClass"><slot></slot></span>
</template>
<script>
    export default {
        name: 'TagBadge',
        props: {
            type: { type: String, default: '' }
        },
        computed: {
            typeClass: function () {
                if (!this.type) return '';
                return 't-' + this.type;
            }
        }
    };
</script>
