<template>
  <div class="app">
    <div class="page-background" v-show="showBgImg"
         :style="'background-image: url(' + appConfig.background + ')'"></div>
    <span class="i2f-back-top-bottom" top-selector=".top-section" bottom-selector=".bottom-section"></span>

    <!-- 顶部导航栏 -->
    <div class="top-bar" v-show="!printMode">
      <div class="logo app-logo" @click="clickAppLogo">&#128196; {{appConfig.title}}</div>
      <div class="breadcrumb">
        <span class="sep">/</span>
        <span class="current crumb-file">{{currentFilePath}}</span>
      </div>
      <button class="home-btn print-page" @click="printPage" title="打印页面">&#128424;</button>
      <a class="home-btn" href="#" @click.prevent="clickHome">&#127968; 首页</a>
      <button class="home-btn bgimg-btn" @click="toggleShowBgImg" title="显示/关闭背景图片">&#127748;</button>
      <button class="home-btn theme-btn" @click="toggleTheme" title="切换深色/浅色主题">
        {{isDark ? '\u2600\uFE0F' : '\uD83C\uDF19'}}
      </button>
    </div>

    <!-- 移动端侧边栏遮罩层 -->
    <div class="sidebar-overlay" v-show="!printMode" @click="clickSidebarOverlay"></div>

    <!-- 主布局 -->
    <div class="layout">
      <nav class="sidebar" v-show="!printMode">
        <div class="sidebar-header">目录导航</div>
        <div class="toc-search-wrap">
          <input class="toc-search" ref="tocSearchRef" v-model="tocSearch" @change="filterToc" type="text"
                 placeholder="🔍搜索标题..." autocomplete="off"
                 spellcheck="false"/>
          <button class="toc-search-clear" v-show="tocSearch" @click="resetTocSearch" title="清除">&#10005;
          </button>
        </div>
        <div class="toc-container">
          <div style="padding:20px 14px;color:var(--text-muted);font-size:.8rem;">加载中...</div>
          <div class="toc-no-match">未找到匹配的标题</div>
        </div>
      </nav>
      <div class="content-wrap">
        <span class="top-section" style="display: block;width: 0;height: 0;opacity: 0"></span>
        <div class="content">
          <div class="loading">
            <div class="spinner"></div>
            <span>正在加载文档...</span>
          </div>
        </div>
        <span class="bottom-section" style="display: block;width: 0;height: 0;opacity: 0"></span>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: "App",
  components: {},
  mixins: [],
  data() {
    return {
      appConfig: this.defaultConfig(),
      isDark: false,
      printMode: false,
      showBgImg: true,
      currentFilePath: 'readme.md',
      tocSearch: '',
      scrollSpyObserver: null,
      TEXT_FILE_SUFFIX_LANGS: {
        '.txt': '', '.py': 'python', '.java': 'java', '.sql': 'sql', '.xml': 'xml', '.dtd': 'xml',
        '.yaml': 'yaml', '.yml': 'yaml', '.json': 'json', '.js': 'javascript', '.jsp': 'xml',
        '.properties': 'properties', '.ini': 'ini', '.conf': 'ini', '.cnf': 'ini', '.config': 'ini',
        '.sh': 'shell', '.bat': 'shell', '.cmd': 'shell', '.c': 'cpp', '.h': 'cpp', '.cpp': 'cpp',
        '.hpp': 'cpp', '.cs': 'csharp', '.css': 'css', '.sass': 'css', '.less': 'css', '.go': 'go',
        '.kt': 'kotlin', '.kts': 'kotlin', '.lua': 'lua', '.perl': 'perl', '.scala': 'scala',
        '.ts': 'typescript', '.vbs': 'vbscript', '.log': 'accesslog', '.gitignore': '',
        '.gitattributes': '', '.bnf': '', '.g4': '', '.vue': 'xml', '.csv': '', '.lock': '',
        '.dockerfile': 'dockerfile', '.groovy': 'groovy', '.nginx': 'nginx',
        '.makefile': 'makefile', '.rb': 'ruby', '.rs': 'rust', '.swift': 'swift', '.r': 'r',
        '.m': 'matlab', '.pl': 'perl', '.php': 'php', '.http': 'http'
      },
      TEXT_FILE_NAME_LANGS: {
        'dockerfile': 'dockerfile', 'makefile': 'makefile', 'nginx.conf': 'nginx', 'license': '',
        'jenkinsfile': 'groovy'
      }
    }
  },
  created() {

  },
  mounted() {
    this.init();
    this.initTheme();
    this.watchHashChange();
  },
  watch: {
    tocSearch: {
      immediate: true,
      handler: function (val, old) {
        this.filterToc()
      }
    }
  },
  methods: {
    defaultConfig() {
      return {title: 'Docs', index: 'readme.md', background: ''}
    },
    async init() {
      await this.loadManifest();
      const hashFile = this.getFileFromHash();
      const fileToLoad = (window.location.hash && window.location.hash !== '#') ? hashFile : this.appConfig.index;
      this.loadFile(fileToLoad);
    },
    async loadManifest() {
      try {
        const resp = await fetch('manifest.json?t=' + Date.now());
        if (!resp.ok) {
          throw new Error('not found');
        }
        const data = await resp.json();
        if (data.title) {
          this.appConfig.title = String(data.title);
        }
        if (data.index) {
          this.appConfig.index = String(data.index).replace(/^\.\//, '');
        }
        if (data.background) {
          this.appConfig.background = String(data.background);
        }
      } catch (e) { /* 保持默认配置 */
      }
      document.querySelector('head title').textContent = this.appConfig.title;
    },
    clickHome() {
      this.navigateTo(this.appConfig.index)
    },
    initTheme() {
      const saved = localStorage.getItem('theme');
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      this.isDark = saved ? saved === 'dark' : prefersDark;
      this.applyTheme();
    },
    toggleTheme() {
      this.isDark = !document.body.classList.contains('dark');
      this.applyTheme();
    },
    applyTheme() {
      const HLJS_LIGHT = '/styles/github.min.css';
      const HLJS_DARK = '/styles/github-dark.min.css';

      document.body.classList.toggle('dark', this.isDark);

      let dom = document.querySelector('#hljs-css');
      let href = dom.href;
      let hljsLightHref = href;
      let hljsDarkHref = href;
      let path = href.match(/\/styles\/github(\-dark)?\.min\.css/)[0];
      hljsDarkHref = href.replace(path, HLJS_DARK);
      hljsLightHref = href.replace(path, HLJS_LIGHT);

      dom.href = this.isDark ? hljsDarkHref : hljsLightHref;
      localStorage.setItem('theme', this.isDark ? 'dark' : 'light');
    },
    watchHashChange() {
      window.addEventListener('hashchange', () => {
        let filePath = this.getFileFromHash();
        this.loadFile(filePath);
      });

      window.addEventListener('resize', () => {
        if (window.innerWidth > 580) {
          document.body.classList.remove('sidebar-open');
        } else {
          document.body.classList.remove('sidebar-collapsed');
        }
      });
    },
    navigateTo(filePath) {
      const clean = filePath.replace(/^\.\//, '').replace(/^#/, '');
      const encoded = encodeURIComponent(clean);
      const current = decodeURIComponent((location.hash || '#').slice(1));
      if (current !== clean) {
        location.hash = '#' + encoded;
      } else {
        this.loadFile(clean);
      }
    },
    printPage() {
      this.showBgImg = false;
      this.printMode = true;
      document.body.style.height = 'auto';
      document.body.style.overflow = 'auto';
      document.querySelector('.app').style.overflow='unset';
      document.querySelector('.app').style.height='unset';
      this.$nextTick(() => {
        window.print();
      })
    },
    toggleShowBgImg() {
      this.showBgImg = !this.showBgImg;
    },
    clickSidebarOverlay() {
      document.body.classList.remove('sidebar-open');
    },
    clickAppLogo() {
      if (window.innerWidth <= 580) {
        document.body.classList.toggle('sidebar-open');
      } else {
        document.body.classList.toggle('sidebar-collapsed');
      }
    },
    closeSidebarOnMobile() {
      if (window.innerWidth <= 580) {
        document.body.classList.remove('sidebar-open');
      }
    },
    /**
     * 加载并渲染文件
     * @param filePath
     * @returns {Promise<void>}
     */
    async loadFile(filePath) {
      filePath = filePath.replace(/^\.\//, '').replace(/^#/, '');
      this.currentFilePath = filePath;
      document.title = filePath + ' — ' + this.appConfig.title;

      const content = document.querySelector('.content');
      content.innerHTML = '<div class="loading"><div class="spinner"></div><span>正在加载 ' + this.escapeHtml(filePath) + ' ...</span></div>';
      document.querySelector('.toc-container').innerHTML =
          '<div style="padding:16px 14px;color:var(--text-muted);font-size:.8rem;">加载中...</div>' +
          '<div class="toc-no-match">未找到匹配的标题</div>';
      this.resetTocSearch();
      document.querySelector('.content-wrap').scrollTop = 0;

      if (!this.isMdFile(filePath)) {
        if (this.isTextFile(filePath)) {
          try {
            const resp = await fetch(filePath + '?t=' + Date.now());
            if (!resp.ok) {
              throw new Error('HTTP ' + resp.status + ': ' + resp.statusText);
            }
            const textContent = await resp.text();
            const lang = this.getFileLang(filePath);
            const validLang = lang && hljs.getLanguage(lang) ? lang : 'text';
            const fileName = filePath.split('/').pop();
            const fid = this.headingId(fileName);
            // 使用 markdown-it 渲染为代码块格式
            const mdContent = '```' + validLang + '\n' + textContent + '\n```';
            content.innerHTML = '<h1 id="' + fid + '">' + this.escapeHtml(fileName) + '</h1>' + this.$md.renderMarkdown(mdContent);
            this.buildToc(content);
          } catch (err) {
            content.innerHTML = '<div class="error-msg"><div style="font-size:2rem">&#10060;</div><strong>加载失败：' + this.escapeHtml(err.message) + '</strong><div style="font-size:.8rem;color:var(--text-muted)">文件路径: <code>' + this.escapeHtml(filePath) + '</code></div></div>';
            document.querySelector('.toc-container').innerHTML = '<div style="padding:16px 14px;color:var(--text-muted);font-size:.8rem;">加载失败</div>';
          }
          return;
        }
        content.innerHTML = '<div class="non-md-notice"><strong>&#9432; 提示：</strong>该文件 <code>' + this.escapeHtml(filePath) + '</code> 不是 Markdown 文件，无法在此渲染。<br/><a href="' + filePath + '" target="_blank">点击此处在新窗口中打开</a></div>';
        document.querySelector('.toc-container').innerHTML = '<div style="padding:16px 14px;color:var(--text-muted);font-size:.8rem;">-</div>';
        return;
      }

      try {
        const resp = await fetch(filePath + '?t=' + Date.now());
        if (!resp.ok) {
          throw new Error('HTTP ' + resp.status + ': ' + resp.statusText);
        }
        const mdText = await resp.text();
        this.renderMdPage(mdText, content);
      } catch (err) {
        content.innerHTML = '<div class="error-msg"><div style="font-size:2rem">&#10060;</div><strong>加载失败：' + this.escapeHtml(err.message) + '</strong><div style="font-size:.8rem;color:var(--text-muted)">文件路径: <code>' + this.escapeHtml(filePath) + '</code><br/>请确保文件存在，且静态文件服务已正确配置。</div></div>';
        document.querySelector('.toc-container').innerHTML = '<div style="padding:16px 14px;color:var(--text-muted);font-size:.8rem;">加载失败</div>';
      }
    },
    getFileFromHash() {
      const hash = decodeURIComponent(location.hash);
      if (!hash || hash === '#' || hash === '#/') {
        return this.appConfig.index || this.defaultConfig().index || 'readme.md';
      }
      const raw = hash.startsWith('#') ? hash.slice(1) : hash;
      return raw.replace(/^\.\//, '');
    },
    getRelativePath(from, to) {
      const fromUrl = new URL(from, location.origin);
      const toUrl = new URL(to, location.origin);

      // 如果协议或域名不同，无法计算相对路径，直接返回绝对路径
      if (fromUrl.origin !== toUrl.origin) {
        return toUrl.href;
      }

      const fromParts = fromUrl.pathname.split('/').filter(Boolean);
      const toParts = toUrl.pathname.split('/').filter(Boolean);

      // 找到公共前缀长度
      let commonLen = 0;
      const minLen = Math.min(fromParts.length, toParts.length);
      for (let i = 0; i < minLen; i++) {
        if (fromParts[i] === toParts[i]) {
          commonLen++;
        } else {
          break;
        }
      }

      // from 的目录部分需要往上退几级（去掉最后一段文件名）
      const upCount = fromParts.length - 1 - commonLen;
      const ups = upCount > 0 ? '../'.repeat(upCount) : '';

      // to 剩余的路径部分
      const remaining = toParts.slice(commonLen).join('/');

      // 拼接结果
      let result = ups + remaining;

      // 保留 to 的 query 和 hash
      result += toUrl.search + toUrl.hash;

      return result || './';
    },
    resolvePath(basePath, relativePath) {
      if (/^https?:\/\//i.test(relativePath)) {
        return relativePath;
      }

      let baseUrl = new URL(basePath, window.location.href).href;
      let relativeUrl = new URL(relativePath, baseUrl).href;
      return this.getRelativePath(window.location.href, relativeUrl)

    },

    getFileBaseName(path) {
      if (!path || path === '') {
        return '';
      }
      const cleanPath = path.split('?')[0];
      let idx = cleanPath.lastIndexOf('/');
      return idx >= 0 ? cleanPath.substring(idx + 1) : cleanPath;
    },

    getFileSuffix(path) {
      if (!path || path === '') {
        return '';
      }
      path = this.getFileBaseName(path);
      let idx = path.lastIndexOf('.');
      return idx >= 0 ? path.substring(idx) : '';
    },

    isMdFile(path) {
      return this.getFileSuffix(path).toLowerCase() === '.md';
    },

    escapeHtml(str) {
      return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    },

    hasNoPreviewParam(href) {
      if (!href) {
        return false;
      }
      let idx = href.indexOf('?');
      if (idx < 0) {
        return false;
      }
      href = href.substring(idx + 1);
      idx = href.indexOf('#');
      if (idx >= 0) {
        href = href.substring(0, idx);
      }
      let urlParams = new URLSearchParams(href);
      let val = urlParams.get('_preview');
      return val === 'no' || val === '0' || val === 'false';
    },
    isTextFile(path) {
      const name = this.getFileBaseName(path).toLowerCase();
      if (name in this.TEXT_FILE_NAME_LANGS) {
        return true;
      }
      const ext = this.getFileSuffix(path).toLowerCase();
      return ext in this.TEXT_FILE_SUFFIX_LANGS;
    },
    getFileLang(path) {
      const name = this.getFileBaseName(path).toLowerCase();
      let lang = this.TEXT_FILE_NAME_LANGS[name];
      if (lang) {
        return lang;
      }
      const ext = this.getFileSuffix(path).toLowerCase();
      lang = this.TEXT_FILE_SUFFIX_LANGS[ext];
      return lang || '';
    },
    isVideoFile(path) {
      return ['.mp4', '.webm', '.mov', '.mkv', '.avi', '.flv'].includes(this.getFileSuffix(path).toLowerCase());
    },
    isAudioFile(path) {
      return ['.mp3', '.wav', '.ogg', '.aac', '.flac', '.m4a', '.wma'].includes(this.getFileSuffix(path).toLowerCase());
    },
    isPdfFile(path) {
      return this.getFileSuffix(path).toLowerCase() === '.pdf';
    },
    headingId(text) {
      return text.toLowerCase().replace(/<[^>]+>/g, '').replace(/[^\w\u4e00-\u9fa5\- ]/g, '').trim().replace(/\s+/g, '-');
    },
    /**
     * 后处理：标题 ID 注入
     * @param container
     */
    injectHeadingIds(container) {
      container.querySelectorAll('h1,h2,h3,h4,h5,h6').forEach(h => {
        if (!h.id) {
          h.id = this.headingId(h.textContent);
        }
      });
    },
    /**
     * 后处理：链接处理（md文件跳转、媒体渲染、PDF预览）
     * @param container
     */
    postProcessLinks(container) {
      container.querySelectorAll('a[href]').forEach(a => {
        const href = a.getAttribute('href');
        if (!href) {
          return;
        }
        const text = a.textContent;

        // 外链处理
        if (/^https?:\/\//i.test(href)) {
          // 视频
          if (this.isVideoFile(href) && !this.hasNoPreviewParam(href)) {
            const fn = this.getFileBaseName(href);
            const dn = (fn === text ? fn : (text + '[' + fn + ']')) || fn || text;
            a.outerHTML = '<div class="media-wrapper"><div class="media-label"><a href="' + href + '" target="_blank">&#127925; ' + this.escapeHtml(dn) + '</a></div><video src="' + href + '" controls style="max-width:100%;" title="' + (a.title || '') + '">' + text + '</video></div>';
            return;
          }
          // 音频
          if (this.isAudioFile(href) && !this.hasNoPreviewParam(href)) {
            const fn = this.getFileBaseName(href);
            const dn = (fn === text ? fn : (text + '[' + fn + ']')) || fn || text;
            a.outerHTML = '<div class="media-wrapper"><div class="media-label"><a href="' + href + '" target="_blank">&#127925; ' + this.escapeHtml(dn) + '</a></div><audio src="' + href + '" controls title="' + (a.title || '') + '">' + text + '</audio></div>';
            return;
          }
          // PDF
          if (this.isPdfFile(href) && !this.hasNoPreviewParam(href)) {
            const fn = this.getFileBaseName(href);
            const dn = (fn === text ? fn : (text + '[' + fn + ']')) || fn || text;
            a.outerHTML = '<div class="media-wrapper"><div class="media-label"><a href="' + href + '" target="_blank">&#127925; ' + this.escapeHtml(dn) + '</a></div><object style="width:100%;" width="100%" height="' + (window.innerHeight - 160) + 'px" data="' + href + '#navpanes=0&amp;toolbar=0" type="application/pdf"><div style="width:100%;text-align:center;margin:5px;">您的浏览器不支持预览PDF！请点击查看</div></object></div>';
            return;
          }
          a.setAttribute('target', '_blank');
          a.setAttribute('rel', 'noopener');
          return;
        }

        // 相对路径
        const resolved = this.resolvePath(this.currentFilePath, href);

        // 视频/音频/PDF（相对路径）
        if (this.isVideoFile(resolved) && !this.hasNoPreviewParam(href)) {
          const fn = this.getFileBaseName(href);
          const dn = (fn === text ? fn : (text + '[' + fn + ']')) || fn || text;
          const rHref = resolved;
          a.outerHTML = '<div class="media-wrapper"><div class="media-label"><a href="' + rHref + '" target="_blank">&#127925; ' + this.escapeHtml(dn) + '</a></div><video src="' + rHref + '" controls style="max-width:100%;" title="' + (a.title || '') + '">' + text + '</video></div>';
          return;
        }
        if (this.isAudioFile(resolved) && !this.hasNoPreviewParam(href)) {
          const fn = this.getFileBaseName(href);
          const dn = (fn === text ? fn : (text + '[' + fn + ']')) || fn || text;
          const rHref = resolved;
          a.outerHTML = '<div class="media-wrapper"><div class="media-label"><a href="' + rHref + '" target="_blank">&#127925; ' + this.escapeHtml(dn) + '</a></div><audio src="' + rHref + '" controls title="' + (a.title || '') + '">' + text + '</audio></div>';
          return;
        }
        if (this.isPdfFile(resolved) && !this.hasNoPreviewParam(href)) {
          const fn = this.getFileBaseName(href);
          const dn = (fn === text ? fn : (text + '[' + fn + ']')) || fn || text;
          const rHref = resolved;
          a.outerHTML = '<div class="media-wrapper"><div class="media-label"><a href="' + rHref + '" target="_blank">&#127925; ' + this.escapeHtml(dn) + '</a></div><object style="width:100%;" width="100%" height="' + (window.innerHeight - 160) + 'px" data="' + rHref + '#navpanes=0&amp;toolbar=0" type="application/pdf"><div style="width:100%;text-align:center;margin:5px;">您的浏览器不支持预览PDF！请点击查看</div></object></div>';
          return;
        }

        // md 文件或文本文件：拦截为站内导航
        if (this.isMdFile(resolved) || this.isTextFile(resolved)) {
          a.setAttribute('data-md-link', resolved);
          a.setAttribute('href', '#' + encodeURIComponent(resolved));
        }
      });
    },
    /**
     * 后处理：图片处理（相对路径解析 + 媒体包装）
     * @param container
     */
    postProcessImages(container) {
      container.querySelectorAll('img').forEach(img => {
        let src = img.getAttribute('src');
        if (!src) return;
        if (!(/^https?:\/\//i.test(src))) {
          src = this.resolvePath(this.currentFilePath, src);
          img.setAttribute('src', src);
        }
        if (this.hasNoPreviewParam(src)) {
          const fn = this.getFileBaseName(src);
          const alt = img.getAttribute('alt') || fn;
          img.outerHTML = '<a href="' + src + '" target="_blank">&#127925; ' + this.escapeHtml(alt) + '</a>';
          return;
        }
        const fn = this.getFileBaseName(src);
        const alt = img.getAttribute('alt') || fn;
        const wrapper = document.createElement('div');
        wrapper.className = 'media-wrapper';
        wrapper.innerHTML = '<div class="media-label"><a href="' + src + '" target="_blank">&#127925; ' + this.escapeHtml(alt) + '</a></div>';
        const newImg = img.cloneNode(true);
        newImg.style.cssText = 'max-width:100%;height:auto;display:block;';
        wrapper.appendChild(newImg);
        img.replaceWith(wrapper);
      });
    },
    /**
     * 目录生成
     * @param container
     */
    buildToc(container) {
      const headings = container.querySelectorAll('h1,h2,h3,h4,h5,h6');
      const tocEl = document.querySelector('.toc-container');
      if (headings.length === 0) {
        tocEl.innerHTML = '<div style="padding:16px 14px;color:var(--text-muted);font-size:.8rem;">本文档无标题目录</div>';
        return;
      }
      const items = [];
      headings.forEach(h => {
        const level = parseInt(h.tagName[1]);
        const text = h.textContent.trim().replace('<', '&lt;').replace('>', '&gt;');
        const id = h.id || this.headingId(text);
        h.id = id;
        items.push({level, text, id});
      });
      tocEl.innerHTML = items.map(item =>
          '<a class="toc-item h' + item.level + '" href="#' + encodeURIComponent(item.id) + '" data-anchor="' + item.id + '" title="' + item.text + '">' + item.text + '</a>'
      ).join('');

      tocEl.querySelectorAll('.toc-item[data-anchor]').forEach(a => {
        a.addEventListener('click', e => {
          e.preventDefault();
          const target = document.getElementById(a.dataset.anchor);
          if (target) {
            target.scrollIntoView({behavior: 'smooth', block: 'start'});
          }
          this.closeSidebarOnMobile();
        });
      });
      this.setupScrollSpy(items.map(i => i.id));
    },
    /**
     * 滚动监听 - 高亮目录当前项
     * @param ids
     */
    setupScrollSpy(ids) {
      if (this.scrollSpyObserver) {
        this.scrollSpyObserver.disconnect();
      }
      const tocEl = document.querySelector('.toc-container');
      const contentWrap = document.querySelector('.content-wrap');
      const headerOffset = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--header-height')) || 52;
      this.scrollSpyObserver = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const id = entry.target.id;
            tocEl.querySelectorAll('.toc-item').forEach(a => {
              a.classList.toggle('active', a.dataset.anchor === id);
            });
            const active = tocEl.querySelector('.toc-item.active');
            if (active) active.scrollIntoView({block: 'nearest'});
          }
        });
      }, {root: contentWrap, rootMargin: '-' + headerOffset + 'px 0px -70% 0px', threshold: 0});
      ids.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
          this.scrollSpyObserver.observe(el);
        }
      });
    },
    renderMdPage(mdText, container) {
      container.innerHTML = this.$md.renderMarkdown(mdText);
      this.injectHeadingIds(container);
      this.postProcessImages(container);
      this.postProcessLinks(container);
      this.buildToc(container);
      this.bindMdLinks(container);
    },
    /**
     * 绑定 md 文件内部链接的跳转行为
     * @param container
     */
    bindMdLinks(container) {
      container.querySelectorAll('a[data-md-link]').forEach(a => {
        a.addEventListener('click', e => {
          e.preventDefault();
          this.navigateTo(a.dataset.mdLink);
          this.closeSidebarOnMobile();
        });
      });
    },
    filterToc() {
      const query = this.tocSearch;
      const q = query.trim().toLowerCase();
      const items = document.querySelectorAll('.toc-container .toc-item');
      let matchCount = 0;
      items.forEach(item => {
        const hit = !q || item.textContent.trim().toLowerCase().includes(q);
        item.style.display = hit ? '' : 'none';
        if (hit) matchCount++;
      });
      const noMatch = document.querySelector('.toc-no-match');
      if (noMatch) {
        noMatch.style.display = (q && matchCount === 0) ? 'block' : 'none';
      }
    },
    resetTocSearch() {
      this.tocSearch = '';
      this.filterToc();
      this.$refs.tocSearchRef.focus();
    }
  }
}
</script>

<style scoped>

</style>