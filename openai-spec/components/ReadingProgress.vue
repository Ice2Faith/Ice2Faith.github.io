<template>
    <div class="reading-progress" :style="{ width: progress + '%' }"></div>
</template>

<script>
    export default {
        name: 'ReadingProgress',
        computed: {
            progress: function () {
                return window.$specState.progress;
            }
        }
    };
</script>