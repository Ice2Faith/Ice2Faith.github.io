<template>
    <div class="markdown-code-block">
        <div class="markdown-code-header">
            <span class="markdown-header-lang">
                <span class="header-lang-dot"></span>{{ lang }}
            </span>
            <span class="markdown-header-actions">
                <span class="action-btn" @click="onSave" title="保存文件">
                    <i class="el-icon-download"></i>
                </span>
                <span class="action-btn" @click="onCopy" title="复制代码">
                    <i class="el-icon-copy-document"></i>
                </span>
            </span>
        </div>
        <pre class="hljs markdown-code-body" :class="richClass"><code v-html="highlightedCode"></code></pre>
    </div>
</template>
<script>
    export default {
        name: 'CodeBlock',
        props: {
            lang: { type: String, default: 'text' },
            code: { type: String, default: '' }
        },
        data: function () {
            return {
                highlightedCode: '',
                chartId: ''
            };
        },
        computed: {
            richClass: function () {
                if (this.lang === 'mermaid') return 'rich-code-block mermaid-code-block';
                if (this.lang === 'svg') return 'rich-code-block svg-code-block';
                return '';
            }
        },
        watch:{
          lang:{
            immediate: true,
            handler:function(val,old){
              this.onChange()
            }
          },
          code:{
            immediate: true,
            handler:function(val,old){
              this.onChange()
            }
          }
        },
        mounted: function () {
            this.onChange();
        },
        methods: {
          onChange(){
            var self = this;
            self.chartId = (self.lang || 'code') + '_' + Date.now() + '_' + Math.random().toString(16).substring(2);
            self.$nextTick(function () {
              if (self.lang === 'mermaid') {
                var dom = self.$el.querySelector('pre');
                if (dom) {
                  dom.id = self.chartId;
                  dom.chartCode = self.code;
                  renderMermaid(dom, self.code);
                }
              } else if (self.lang === 'svg') {
                var dom = self.$el.querySelector('pre');
                if (dom) {
                  dom.id = self.chartId;
                  dom.chartCode = self.code;
                  renderSvg(dom, self.code);
                }
              } else {
                self.highlight();
              }
            });
          },
            highlight: function () {
                var lang = this.lang || 'text';
                var code = this.code || '';
                if (lang !== 'text' && typeof hljs !== 'undefined' && hljs.getLanguage(lang)) {
                    try {
                        this.highlightedCode = hljs.highlight(code, { language: lang }).value;
                    } catch (e) {
                        this.highlightedCode = this.escapeHtml(code);
                    }
                } else {
                    this.highlightedCode = this.escapeHtml(code);
                }
            },
            escapeHtml: function (str) {
                return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            },
            onSave: function () {
                var blob = new Blob([this.code], { type: 'plain/text;charset=utf-8' });
                var url = URL.createObjectURL(blob);
                var link = document.createElement('a');
                var ext = (this.lang === 'svg') ? 'svg' : 'txt';
                link.href = url;
                link.download = (this.lang || 'text') + '_' + Date.now() + '.' + ext;
                link.click();
                URL.revokeObjectURL(url);
            },
            onCopy: function () {
                if (typeof copy2clipboard === 'function') {
                    copy2clipboard(this.code);
                }
            }
        }
    };
</script>
