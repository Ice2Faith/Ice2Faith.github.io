/**
 * 上下滚动组件
 * 使用方式
 * 引入样式和JS
 * <link rel="stylesheet" href="./i2f-back-top-bottom.css"/>
 * <script src="./i2f-back-top-bottom.js"></script>
 *
 * 添加元素，元素内部要为为空内容，因为会自动注入内部样式与元素
 * <span class="i2f-back-top-bottom" top-selector=".top-section" bottom-selector=".bottom-section"></span>
 *
 * 在代码中添加元素，为元素添加 class 为 i2f-back-top-bottom 即可赋予悬浮滚动功能
 * 可使用 top-selector 指定滚动到头部的元素选择器，不设置则滚动到页面顶部
 * 可使用 bottom-selector 指定滚动到底部的元素选择器，不设置则股东到页面底部
 */
(() => {
    'use strict';

    function initI2fBackTopBottomBtn() {
        const scrollToType = (type, selector) => {
            let resolved = false;
            if (selector) {
                const target = document.querySelector(selector);
                if (!target) {
                    console.warn(`not found selector: ${selector}`);
                } else {
                    target.scrollIntoView({
                        behavior: 'smooth', // 平滑滚动
                        block: 'start' // 滚动到元素顶部
                    });
                    resolved = true;
                }
            }
            if (!resolved) {
                if (type == 'top') {
                    window.scrollTo({
                        top: 0,
                        behavior: 'smooth'
                    });
                } else if (type == 'bottom') {
                    const getDocHeight = () => Math.max(
                        document.body?.scrollHeight || 0,
                        document.documentElement?.scrollHeight || 0,
                        document.body?.offsetHeight || 0,
                        document.documentElement?.offsetHeight || 0,
                        document.body?.clientHeight || 0,
                        document.documentElement?.clientHeight || 0
                    );

                    window.scrollTo({
                        top: getDocHeight(),
                        behavior: 'smooth'
                    });
                }
            }
        };

        let list = document.querySelectorAll('.i2f-back-top-bottom');
        for (let i = 0; i < list.length; i++) {
            let dom = list[i]
            if (!dom.dataset.initBackTopBottom) {
                let html = dom.innerHTML;
                if (html) {
                    html = html.trim();
                }
                if (!html) {
                    dom.innerHTML = `<div class="i2f-back-top-bottom-btn i2f-back-top-bottom-btn-top"  title="滚动到顶部">
                            <svg viewBox="0 0 24 24"><path d="M12 4l-8 8h5v8h6v-8h5z"/></svg>
                        </div>

                        <div class="i2f-back-top-bottom-btn i2f-back-top-bottom-btn-bottom" title="滚动到底部">
                            <svg viewBox="0 0 24 24"><path d="M12 20l8-8h-5V4H9v8H4z"/></svg>
                        </div>`;
                }
                dom.dataset.initBackTopBottom = true;
            }
        }

        for (let i = 0; i < list.length; i++) {
            let dom = list[i]
            let topSelector = dom.getAttribute('top-selector');
            let bottomSelector = dom.getAttribute('bottom-selector');
            let topBtn = dom.querySelector('.i2f-back-top-bottom-btn-top');
            let bottomBtn = dom.querySelector('.i2f-back-top-bottom-btn-bottom');
            if (!topBtn.dataset.initBackTopBottom) {
                topBtn.addEventListener('click', () => scrollToType('top', topSelector));
                topBtn.dataset.initBackTopBottom = true;
            }
            if (!bottomBtn.dataset.initBackTopBottom) {
                bottomBtn.addEventListener('click', () => scrollToType('bottom', bottomSelector));
                bottomBtn.dataset.initBackTopBottom = true;
            }
        }
    }

    // DOM 加载完成后绑定事件
    document.addEventListener('DOMContentLoaded', () => {
        initI2fBackTopBottomBtn();
        setInterval(() => {
            initI2fBackTopBottomBtn();
        }, 3000)
    });
})();