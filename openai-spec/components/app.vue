<template>
    <div>
        <ReadingProgress />
        <AppNav />
        <div class="side-nav-overlay" :class="{ open: navOpen }" @click="closeNav"></div>
        <div class="layout">
            <SideNav />
            <main class="main-content">
                <Masthead />
                <MetaTable />
                <StatGrid />
                <ChapterSection v-for="ch in spec.chapters" :key="ch.id" :chapter="ch" />
                <AppFooter />
            </main>
        </div>
        <BackToTop />
    </div>
</template>

<header>
    <title>OpenAI 兼容 AI 对话框架 · 技术全景</title>
</header>

<script>
    export default {
        name: 'App',
        components: {
            ReadingProgress: './ReadingProgress.vue',
            AppNav: './AppNav.vue',
            SideNav: './SideNav.vue',
            Masthead: './Masthead.vue',
            MetaTable: './MetaTable.vue',
            StatGrid: './StatGrid.vue',
            ChapterSection: './ChapterSection.vue',
            AppFooter: './AppFooter.vue',
            BackToTop: './BackToTop.vue'
        },
        data: function () {
            return {
                spec: window.$spec,
                state: window.$specState,
                scrollTimer: null
            };
        },
        methods: {
            /* ---------- 滚动处理 ---------- */
            onScroll: function () {
                var self = this;
                var scrollY = window.scrollY;
                var docHeight = document.documentElement.scrollHeight - window.innerHeight;
                if (docHeight > 0) {
                    self.state.progress = Math.round((scrollY / docHeight) * 100);
                }
                self.state.showBackTop = scrollY > 400;
                self.updateActiveNav();
            },

            /* ---------- 更新激活导航 ---------- */
            updateActiveNav: function () {
                var self = this;
                var bestId = 'ch01';
                var bestTop = Infinity;
                self.spec.chapters.forEach(function (ch) {
                    var el = document.getElementById(ch.id);
                    if (!el) return;
                    var rect = el.getBoundingClientRect();
                    var top = Math.abs(rect.top - 100);
                    if (rect.top < window.innerHeight / 2 && top < bestTop) {
                        bestTop = top;
                        bestId = ch.id;
                    }
                });
                self.state.activeNavId = bestId;
            },

            /* ---------- 关闭导航 ---------- */
            closeNav: function () {
                window.$specState.navOpen = false;
            }
        },
        mounted: function () {
            var self = this;
            self.$nextTick(function () {
                /* 初始化 GSAP 动画系统 */
                if (window.$gsap) {
                    window.$gsap.initAll();
                }
                /* 异步组件加载后刷新动画扫描 */
                setTimeout(function () {
                    if (window.$gsap) {
                        window.$gsap.refresh();
                    }
                }, 2000);
            });
            window.addEventListener('scroll', function () {
                if (self.scrollTimer) return;
                self.scrollTimer = setTimeout(function () {
                    self.scrollTimer = null;
                    self.onScroll();
                }, 50);
            }, { passive: true });
            self.onScroll();
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape' && self.state.navOpen) {
                    self.state.navOpen = false;
                }
            });
        }
    };
</script>
