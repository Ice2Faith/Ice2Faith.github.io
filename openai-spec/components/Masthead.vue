<template>
    <section class="masthead">
        <MastheadContent />
    </section>
</template>

<script>
    export default {
        name: 'Masthead',
        components: {
            MastheadContent: './chapters/MastheadContent.vue'
        }
    };
</script>