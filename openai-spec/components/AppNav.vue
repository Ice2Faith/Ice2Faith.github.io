<template>
    <header class="boot-strip" :class="{ 'nav-visible': navOpen }">
        <div class="boot-inner">
            <button class="nav-toggle" @click="toggleNav" :aria-label="navOpen ? '关闭导航' : '打开导航'">
              <span></span><span></span><span></span>
            </button>
            <div class="boot-brand">
                <span class="boot-logo">⚙</span>
                <span class="boot-title">
                  <a href="https://gitee.com/ice2faith/i2f-turbo-java/tree/main/i2f-springboot/i2f-springboot-ops-starter" target="_blank">
                     i2f-springboot-ops-starter
                  </a>
                </span>
                <span class="boot-pipe">|</span>
                <span class="boot-sub">OpenAI 子系统 · 技术全景</span>
            </div>
            <nav class="boot-nav">
                <a v-for="n in spec.nav" :key="n.id"
                   :class="{ active: activeNavId === n.id }"
                   @click.prevent="scrollToChapter(n.id)"
                   href="javascript:void(0)">
                    <span class="bn-no">{{ n.no }}</span>
                    <span class="bn-title">{{ n.title }}</span>
                </a>
            </nav>
        </div>
    </header>
</template>

<script>
    export default {
        name: 'AppNav',
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
            scrollToChapter: function (id) {
                window.$specUtils.scrollToChapter(id);
            },
            toggleNav: function () {
                window.$specState.navOpen = !window.$specState.navOpen;
            }
        }
    };
</script>