<template>
  <div>
    <div class="kicker">i2f.springboot.ops.openai · 技术全景文档</div>
    <h1 ref="titleText">OpenAI 兼容<br><span class="hl">AI 对话框架</span>设计全景</h1>
    <p class="sub" ref="subText">内嵌于运维控制台的<b>胖客户端式</b> AI 对话子系统：以 OpenAI 兼容协议为骨架，以 <b>Re-Act 循环</b>为心脏，串联 Function Calling 工具体系、技能系统、RAG 知识库、MCP 动态工具与国密全链路安全传输，兼容 OpenAI / DashScope / Ollama / vLLM 等一切兼容服务。</p>
    <div ref="terminalText" class="term-line">
      <span class="prompt">ops&gt;</span>
      <span>POST /ops/open-ai/stream</span>
      <span class="arrow">→</span>
      <span class="sse">text/event-stream</span>
      <span class="caret"></span>
    </div>

    <div class="reveal">
      <DiagramPanel src="assets/diagrams/masthead-loop.svg"
                    caption="核心消息循环 — 一次对话即一轮消息列表的维护与推理"/>
    </div>
  </div>
</template>
<script>
export default {
  name: 'MastheadContent',
  components: {
    DiagramPanel: '../md/DiagramPanel.vue'
  },
  methods: {
    /* 通用打字机动画：从 DOM 读取内容，逐字显示 */
    typeText: function (el, speed, callback) {
      if (!el || !window.gsap) {
        if (callback) callback();
        return;
      }

      var html = el.innerHTML;

      /* 解析 HTML：分离标签和纯文本字符 */
      var tokens = [];
      var i = 0;
      while (i < html.length) {
        if (html[i] === '<') {
          var end = html.indexOf('>', i);
          if (end === -1) break;
          tokens.push({type: 'tag', value: html.substring(i, end + 1)});
          i = end + 1;
        } else {
          tokens.push({type: 'char', value: html[i]});
          i++;
        }
      }

      /* 收集纯文本字符索引 */
      var textIndices = [];
      tokens.forEach(function (t, idx) {
        if (t.type === 'char') textIndices.push(idx);
      });

      var totalChars = textIndices.length;
      if (totalChars === 0) {
        if (callback) callback();
        return;
      }

      /* 初始隐藏并清空 */
      el.style.visibility = 'hidden';
      el.innerHTML = '';

      /* GSAP 打字机动画 */
      var progress = {val: 0};
      window.gsap.to(progress, {
        val: totalChars,
        duration: totalChars * speed,
        ease: 'none',
        onUpdate: function () {
          var count = Math.floor(progress.val);
          var visibleSet = new Set();
          for (var k = 0; k < count && k < textIndices.length; k++) {
            visibleSet.add(textIndices[k]);
          }
          var out = '';
          for (var j = 0; j < tokens.length; j++) {
            if (tokens[j].type === 'tag') {
              out += tokens[j].value;
            } else if (visibleSet.has(j)) {
              out += tokens[j].value;
            }
          }
          el.innerHTML = out;
        },
        onStart: function () {
          el.style.visibility = 'visible';
        },
        onComplete: function () {
          el.innerHTML = html;
          if (callback) callback();
        }
      });
    }
  },
  mounted: function () {
    var self = this;
    /* h1 先打字，完成后 .sub 紧随 */
    self.typeText(self.$refs.titleText, 0.06);
    self.typeText(self.$refs.subText, 0.02);
    self.typeText(self.$refs.terminalText,0.1)
  }
};
</script>
