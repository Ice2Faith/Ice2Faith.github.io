<template>
    <div class="diagram-panel" :style="style">
        <div v-if="type === 'mermaid'" :id="chartId" class="rich-code-block mermaid-code-block"></div>
        <div v-else-if="type === 'svg'" :id="chartId" class="rich-code-block svg-code-block"></div>
        <div v-if="caption" class="dg-cap">{{ caption }}</div>
    </div>
</template>
<script>
    export default {
        name: 'DiagramPanel',
        props: {
            src: { type: String, default: '' },
            caption: { type: String, default: '' },
            type: { type: String, default: 'svg' },
            marginTop: { type: String, default: '' }
        },
        data: function () {
            return {
                chartId: (this.type || 'svg') + '_' + Date.now() + '_' + Math.random().toString(16).substring(2)
            };
        },
        computed: {
            style: function () {
                return this.marginTop ? 'margin-top:' + this.marginTop + ';' : '';
            }
        },
        mounted: function () {
            var self = this;
            self.$nextTick(function () {
                var dom = document.getElementById(self.chartId);
                if (!dom) return;
                if (self.type === 'mermaid' && window.mermaid) {
                    dom.chartCode = self.src;
                    renderMermaid(dom, self.src);
                } else if (self.type === 'svg') {
                    dom.chartCode = self.src;
                    renderSvg(dom, self.src);
                }
            });
        }
    };
</script>
