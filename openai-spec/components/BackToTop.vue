<template>
    <transition name="el-fade-in">
        <button v-show="showBackTop" class="back-top" @click="scrollToTop"
                title="返回顶部">
            <i class="el-icon-top"></i>
        </button>
    </transition>
</template>

<script>
    export default {
        name: 'BackToTop',
        computed: {
            showBackTop: function () {
                return window.$specState.showBackTop;
            }
        },
        methods: {
            scrollToTop: function () {
                window.$specUtils.scrollToTop();
            }
        }
    };
</script>