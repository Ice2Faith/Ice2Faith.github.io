<template>
    <section :id="chapter.id" class="chapter">
        <div class="chapter-header reveal">
            <span class="ch-no">{{ chapter.no }}</span>
            <div class="ch-title-group">
                <span class="ch-en">{{ chapter.en }}</span>
                <h2 class="ch-title">{{ chapter.title }}</h2>
            </div>
        </div>
        <div class="chapter-body">
            <component :is="chapterComponent" />
        </div>
    </section>
</template>

<script>
    var chapterMap = {
        'ch01': 'Ch01Overview',
        'ch02': 'Ch02Design',
        'ch03': 'Ch03Architecture',
        'ch04': 'Ch04Pipeline',
        'ch05': 'Ch05React',
        'ch06': 'Ch06Messages',
        'ch07': 'Ch07Tools',
        'ch08': 'Ch08Skills',
        'ch09': 'Ch09Rag',
        'ch10': 'Ch10Mcp',
        'ch11': 'Ch11Security',
        'ch12': 'Ch12Advanced',
        'ch13': 'Ch13Autoconfig',
        'ch14': 'Ch14Frontend',
        'ch15': 'Ch15Extension'
    };

    export default {
        name: 'ChapterSection',
        props: {
            chapter: {
                type: Object,
                required: true
            }
        },
        components: {
            Ch01Overview: './chapters/Ch01Overview.vue',
            Ch02Design: './chapters/Ch02Design.vue',
            Ch03Architecture: './chapters/Ch03Architecture.vue',
            Ch04Pipeline: './chapters/Ch04Pipeline.vue',
            Ch05React: './chapters/Ch05React.vue',
            Ch06Messages: './chapters/Ch06Messages.vue',
            Ch07Tools: './chapters/Ch07Tools.vue',
            Ch08Skills: './chapters/Ch08Skills.vue',
            Ch09Rag: './chapters/Ch09Rag.vue',
            Ch10Mcp: './chapters/Ch10Mcp.vue',
            Ch11Security: './chapters/Ch11Security.vue',
            Ch12Advanced: './chapters/Ch12Advanced.vue',
            Ch13Autoconfig: './chapters/Ch13Autoconfig.vue',
            Ch14Frontend: './chapters/Ch14Frontend.vue',
            Ch15Extension: './chapters/Ch15Extension.vue'
        },
        computed: {
            chapterComponent: function () {
                return chapterMap[this.chapter.id] || 'div';
            }
        }
    };
</script>