/**
 * GSAP 动画系统 — 工程蓝图风格文档站炫酷效果
 * 依赖：gsap + ScrollTrigger（已在 index.html 加载并注册）
 */
var $gsap = (function () {
    'use strict';

    /* ========== 首页入场动画 ========== */
    function initEntrance() {
        var tl = gsap.timeline({ delay: 0.35 });

        /* 顶部导航条 — 从上方滑入 */
        gsap.from('.boot-strip', {
            y: -60, opacity: 0, duration: 0.6, ease: 'power2.out'
        });

        /* Kicker 标签行 */
        tl.from('.masthead .kicker', {
            x: -50, opacity: 0, duration: 0.65, ease: 'power3.out'
        })
        /* 标题逐行弹入 */
        .from('.masthead h1', {
            y: 50, opacity: 0, duration: 0.85, ease: 'power3.out'
        }, '-=0.3')
        /* 副标题淡入 */
        .from('.masthead .sub', {
            y: 30, opacity: 0, duration: 0.65, ease: 'power2.out'
        }, '-=0.45')
        /* 终端命令行 — 打字机风格从左展开 */
        .from('.term-line', {
            scaleX: 0, opacity: 0, duration: 0.7,
            ease: 'power2.out', transformOrigin: 'left center'
        }, '-=0.3')
        /* 核心循环图 — 从下方浮入 */
        .from('.masthead .diagram-panel', {
            y: 50, opacity: 0, duration: 0.85, ease: 'power2.out'
        }, '-=0.25')
        /* Meta 信息表 */
        .from('.meta-table-wrap', {
            y: 30, opacity: 0, duration: 0.6, ease: 'power2.out'
        }, '-=0.4');
    }

    /* ========== 滚动触发动画（ScrollTrigger batch） ========== */
    function initScrollAnims() {
        /* 通用揭示 — 面板、引言、步骤、双栏、图表等 */
        gsap.utils.toArray('.reveal').forEach(function (el) {
            if (el._gsapReveal) return;
            el._gsapReveal = true;
            gsap.from(el, {
                scrollTrigger: { trigger: el, start: 'top 88%', once: true },
                y: 40, opacity: 0, duration: 0.8, ease: 'power2.out'
            });
        });

        /* 特性卡片 — 交错弹入 */
        gsap.utils.toArray('.card-grid').forEach(function (grid) {
            var cards = grid.querySelectorAll('.card');
            if (!cards.length || grid._gsapCards) return;
            grid._gsapCards = true;
          

            gsap.fromTo(cards,
                { y: 55, opacity: 0, scale: 0.96 },  // 起始状态
                {
                    y: 0, opacity: 1, scale: 1,       // 结束状态
                    scrollTrigger: { trigger: grid, start: 'top 85%', once: true },
                    duration: 0.6,
                    stagger: { each: 0.08, from: 'start' },
                    ease: 'back.out(1.4)'
                }
            );
        });

        /* 引言块 — 左右交替滑入 */
        gsap.utils.toArray('.callout').forEach(function (el, i) {
            if (el._gsapCallout) return;
            el._gsapCallout = true;
            gsap.from(el, {
                scrollTrigger: { trigger: el, start: 'top 88%', once: true },
                x: i % 2 === 0 ? -45 : 45,
                opacity: 0, duration: 0.7, ease: 'power2.out'
            });
        });

        /* 步骤列表 — 逐级滑入 */
        gsap.utils.toArray('.step-list').forEach(function (list) {
            var steps = list.querySelectorAll('.step');
            if (!steps.length || list._gsapSteps) return;
            list._gsapSteps = true;
            gsap.fromTo(steps, { x: -35, opacity: 0, },  // 起始状态
                {
                scrollTrigger: { trigger: list, start: 'top 85%', once: true },
                x: 0, opacity: 1,
                duration: 0.5, stagger: 0.1, ease: 'power2.out'
            });

        });

        /* 包树 / 代码块 — 淡入上浮 */
        gsap.utils.toArray('.pkg-tree, .markdown-code-block').forEach(function (el) {
            if (el._gsapCode) return;
            el._gsapCode = true;
            gsap.from(el, {
                scrollTrigger: { trigger: el, start: 'top 88%', once: true },
                y: 25, opacity: 0, duration: 0.6, ease: 'power2.out'
            });
        });

        /* 表格行 — 交错淡入 */
        gsap.utils.toArray('.spec-table-wrap').forEach(function (wrap) {
            var rows = wrap.querySelectorAll('tbody tr');
            if (!rows.length || wrap._gsapTable) return;
            wrap._gsapTable = true;
            gsap.from(rows, {
                scrollTrigger: { trigger: wrap, start: 'top 85%', once: true },
                opacity: 0, x: -15,
                duration: 0.35, stagger: 0.04, ease: 'power1.out'
            });
        });
    }

    /* ========== 统计数字动画（GSAP 驱动） ========== */
    function initCounters() {
        gsap.utils.toArray('.stat-section').forEach(function (section) {
            if (section._gsapCounter) return;
            var counters = section.querySelectorAll('.stat-count');
            if (!counters.length) return;
            section._gsapCounter = true;

            ScrollTrigger.create({
                trigger: section,
                start: 'top 90%',
                once: true,
                onEnter: function () {
                    counters.forEach(function (el) {
                        var target = parseInt(el.getAttribute('data-target'));
                        gsap.to(el, {
                            innerText: target,
                            duration: 1.4,
                            ease: 'power2.out',
                            snap: { innerText: 1 },
                            onUpdate: function () {
                                el.textContent = Math.round(gsap.getProperty(el, 'innerText'));
                            }
                        });
                    });
                }
            });
        });
    }

    /* ========== 章节编号视差 ========== */
    function initParallax() {
        gsap.utils.toArray('.chapter').forEach(function (ch) {
            var no = ch.querySelector('.ch-no');
            if (!no || ch._gsapParallax) return;
            ch._gsapParallax = true;
            gsap.to(no, {
                y: -18,
                ease: 'none',
                scrollTrigger: {
                    trigger: ch,
                    start: 'top bottom',
                    end: 'bottom top',
                    scrub: 1.2
                }
            });
        });
    }

    /* ========== 公开接口 ========== */
    return {
        initEntrance: initEntrance,
        initScrollAnims: initScrollAnims,
        initCounters: initCounters,
        initParallax: initParallax,
        initAll: function () {
            initEntrance();
            initScrollAnims();
            initCounters();
            initParallax();
        },
        refresh: function () {
            /* 异步内容加载完成后调用，重新扫描新元素 */
            ScrollTrigger.refresh();
            initScrollAnims();
            initCounters();
        }
    };
})();
