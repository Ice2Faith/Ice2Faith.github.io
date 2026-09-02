<template>
    <div class="side-nav-wrap">
        <aside class="side-nav-panel" :class="{ open: navOpen }">
            <div class="side-nav-header">
                <span class="side-nav-title">目录</span>
                <button class="side-nav-close" @click="closeNav">&times;</button>
            </div>
            <nav class="side-nav-list">
                <a v-for="n in spec.nav" :key="n.id"
                   :class="{ active: activeNavId === n.id }"
                   @click.prevent="scrollToChapter(n.id)"
                   href="javascript:void(0)">
                    <span class="sn-no">{{ n.no }}</span>
                    <span class="sn-title">{{ n.title }}</span>
                </a>
            </nav>
        </aside>
    </div>
</template>

<script>
    export default {
        name: 'SideNav',
        computed: {
            spec: function () {
                return window.$spec;
            },
            activeNavId: function () {
                return window.$specState.activeNavId;
            },
            navOpen: function () {
                return window.$specState.navOpen;
            }
        },
        methods: {
            closeNav: function () {
                window.$specState.navOpen = false;
            },
            scrollToChapter: function (id) {
                window.$specUtils.scrollToChapter(id);
            }
        }
    };
</script>