/**
 * i2f-springboot-ops-starter · OpenAI 子系统技术全景
 * 全局共享状态 + 工具函数
 * 通过 window.$specState (Vue.observable) 实现跨组件响应式通信
 */
(function () {
    var spec = getSpecData();

    /* ==================== 全局响应式状态 ==================== */
    window.$specState = Vue.observable({
        progress: 0,
        showBackTop: false,
        activeNavId: 'ch01',
        navOpen: false
    });

    /* ==================== 全局只读数据 ==================== */
    window.$spec = spec;

    /* ==================== 全局工具函数 ==================== */
    window.$specUtils = {
        /**
         * 滚动到指定章节
         */
        scrollToChapter: function (id) {
            window.$specState.navOpen = false;
            var el = document.getElementById(id);
            if (!el) return;
            var top = el.getBoundingClientRect().top + window.scrollY - 80;
            window.scrollTo({ top: top, behavior: 'smooth' });
        },

        /**
         * 滚动到顶部
         */
        scrollToTop: function () {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        },

        /**
         * 复制到剪贴板
         */
        copyToClipboard: function (text) {
            var ta = document.createElement('textarea');
            ta.value = text;
            ta.style.position = 'fixed';
            ta.style.opacity = '0';
            document.body.appendChild(ta);
            ta.select();
            try {
                document.execCommand('copy');
                if (window.app && window.app.$message) {
                    window.app.$message.success('已复制到剪贴板');
                }
            } catch (e) {
                if (window.app && window.app.$message) {
                    window.app.$message.error('复制失败');
                }
            }
            document.body.removeChild(ta);
        }
    };

    /* 快捷别名 */
    window.copy2clipboard = window.$specUtils.copyToClipboard;
})();