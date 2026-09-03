/**
 * 用于将.vue文件直接用于多页面的html中
 * 也能够使用.vue文件进行开发，并尽量支持vue的组件，指令，混入等特性
 * 具体使用，请查看Vue2Loader.createVue的注释
 * @return {Vue2Loader}
 * @constructor {Vue2Loader}
 */
function Vue2Loader() {

}

/**
 *
 * @type {DOMParser}
 */
Vue2Loader.parser = new DOMParser()


/**
 * 使用简单的方式
 * 直接分割VUE模版各个部分
 * 适用要求：返回的标记，最好都独占一行，否则可能解析会出现问题
 * @param content
 * @returns {{template: string, header: string, style: string, script: string}}
 */
function parseVueSFC(content) {
    const lines = content.split('\n');
    const sections = {template: '', script: '', style: '', header: ''};
    // 使用累计栈实现
    let currentContent = ''
    let stack = []

    const startTagRegex = /^\s*<\s*(template|script|style|header)(\s+[^>]*)?>\s*$/;
    const endTagRegex = /^\s*<\s*\/\s*(template|script|style|header)\s*>\s*$/;

    for (const line of lines) {
        const trimmed = line; // 保留原始行用于拼接，但匹配时使用原样（因为正则已处理空白）
        let topSection = stack.length == 0 ? null : stack[stack.length - 1];

        currentContent += line + '\n';

        // 检查是否结束标签
        const endMatch = line.match(endTagRegex);
        if (endMatch) {
            const section = endMatch[1];
            if (topSection === section) {
                stack.pop();
                if (stack.length == 0) {
                    sections[section] = currentContent;
                    currentContent = '';
                }
            }
            continue;
        }

        // 检查是否开始标签
        const startMatch = line.match(startTagRegex);
        if (startMatch) {
            const section = startMatch[1];
            stack.push(section);
        }

    }

    // 异常情况，未完全匹配，还是依旧保留
    if (stack.length > 0) {
        let section = stack[0];
        sections[section] = currentContent;
        currentContent = '';
    }

    let stripTags = function (str, tag) {
        return str.trim().replace(new RegExp(`^\\s*<${tag}[^>]*>\\s*`), '')
            .replace(new RegExp(`\\s*</${tag}>\\s*$`), '');
    }
    // 去除末尾多余换行
    Object.keys(sections).forEach(key => {
        sections[key] = stripTags(sections[key], key);
    });

    return sections;
}

/**
 * 这是按照标准HTML解析的
 * 如果出现非标准HTML的内容
 * 将会被隐式转换
 * 例如：
 * 驼峰命名的标签名会被转换为全小写
 * 自闭的非标准标签，会被转换为只有开始标记，没有结束标记的开放标签
 * 这两种情况都是问题
 * 因此，需要结合实际情况决定是否使用此方法
 * @param html {string}
 * @return {Document}
 */
Vue2Loader.parseHtmlDom = function (html) {
    return Vue2Loader.parser.parseFromString(html, "text/html")
}

/**
 * use random number as uuid
 * this is uuid-3 implements
 * @return {string}
 */
Vue2Loader.randomUUID = function () {
    let ret = ''+new Date().getTime().toString(16).toUpperCase()
    let codes = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for (let i = 0; i < 32; i++) {
        let num = Math.floor(Math.random() * codes.length)
        ret += codes.charAt(num)
    }
    return ret
}

/**
 *
 * @param parent {HTMLElement}
 * @param child {HTMLElement}
 */
Vue2Loader.domAppend = function (parent, child) {
    try {
        parent.append(child)
    } catch (e) {
        parent.appendChild(child)
    }
}

/**
 *
 * @param dom {HTMLElement}
 */
Vue2Loader.domRemove = function (dom) {
    try {
        dom.remove()
    } catch (e) {
        dom.parentNode.removeChild(dom)
    }
}

/**
 *
 * @param elemId {string}
 * @param tagName {string}
 * @param parent {HTMLElement}
 * @return {HTMLElement}
 */
Vue2Loader.domGetOrCreate = function (elemId, tagName, parent) {
    if (!tagName) {
        tagName = 'div'
    }
    if (!parent) {
        parent = document.body
    }
    let dom = document.querySelector('#' + elemId);
    if (!dom) {
        dom = document.createElement(tagName);
        dom.id = elemId
        Vue2Loader.domAppend(parent, dom)
    }
    return dom
}

/**
 *
 * @param dom {HTMLElement}
 * @param html {string}
 */
Vue2Loader.domSetInnerHtml = function (dom, html) {
    try {
        dom.innerHTML = html
    } catch (e) {
        dom.innerText = html
    }
}

/**
 *
 * @param url {string}
 * @param options {Object}
 * @returns {Promise<Object>}
 */
Vue2Loader.fetchXhr = function (url, options) {
    if (!options) {
        options = {}
    }
    if (!options.method) {
        options.method = 'get'
    }
    if (!options.responseType) {
        options.responseType = 'text'
    }
    return new Promise(function (resolve, reject) {
        try {
            if (new URL(url, window.location.href).protocol === 'file:') {
                reject('file protocol un-support')
                return
            }
            let xhr = new XMLHttpRequest();
            xhr.open(options.method, url);
            xhr.responseType = options.responseType
            xhr.onload = function (event) {
                if (this.status === 200) {
                    resolve(this.response)
                } else {
                    reject({
                        status: this.status,
                        statusText: this.statusText
                    })
                }
            }
            xhr.send()
        } catch (e) {
            reject({
                status: this.status,
                statusText: this.statusText
            })
        }
    })
}

/**
 * load an url content by iframe pre tag
 * @param url {string}
 * @return {Promise<string>}
 */
Vue2Loader.fetchIframe = function (url) {
    let jsIframeTxt = false;
    let pathname = new URL(url, window.location.href).pathname;
    if (pathname.endsWith('.iframe.txt')) {
        pathname = pathname.substring(0, pathname.length - '.iframe.txt'.length);
        jsIframeTxt = true;
    }
    let suffix = ''
    let idx = pathname.lastIndexOf('.');
    if (idx >= 0) {
        suffix = pathname.substring(idx).toLowerCase()
    }

    let contentType = Vue2Loader.detectContentTypeBySuffix(suffix)

    if (contentType && contentType.indexOf('charset') < 0) {
        contentType = `${contentType}; charset=utf-8`;
    } else {
        contentType = `application/octet-stream`;
    }

    return new Promise(function (resolve, reject) {
        let frameId = 'vue_frame_' + Vue2Loader.randomUUID().toLocaleLowerCase()
        let frameDom = Vue2Loader.domGetOrCreate(frameId, 'iframe', document.body)
        frameDom.style.display = 'none'
        frameDom.style.width = '0px'
        frameDom.style.height = '0px'
        frameDom.onload = function () {
            try {
                let frameDoc = frameDom.contentDocument || frameDom.contentWindow.document
                let pre = frameDoc.querySelector('body pre')
                let text = pre.innerText

                return new Response(text, {
                    status: 200,
                    statusText: "OK",
                    headers: {
                        // 强烈建议加上 Content-Type，方便下游的 .json() 或 .text() 方法正确解析
                        'Content-Type': contentType
                    }
                });
            } catch (e) {
                reject(e)
            }
            setTimeout(function () {
                Vue2Loader.domRemove(frameDom)
            }, 300)
        }
        frameDom.onerror = function (event, source, lineno, colno, error) {
            reject({
                event: event,
                source: source,
                lineno: lineno,
                colno: colno,
                error: error
            })
            setTimeout(function () {
                Vue2Loader.domRemove(frameDom)
            }, 300)
        }
        frameDom.src = url
    })
}


Vue2Loader._jsonpResources=[]

window.jsonp_callback=function(response){
    Vue2Loader._jsonpResources.push(response)
    setTimeout(()=>{
        Vue2Loader._jsonpResources.splice(0,1)
    },30000)
}

/**
 * load an url content by jsonp
 * @param url {string}
 * @param options {object|null}
 * @return {Promise<Object>}
 */
Vue2Loader.fetchJsonp = function (url, options) {
    if (!options) {
        options = {}
    }

    let isJsonpJs = false;
    let pathname = new URL(url, window.location.href).pathname;
    if (pathname.endsWith('.jsonp.js')) {
        pathname = pathname.substring(0, pathname.length - '.jsonp.js'.length);
        isJsonpJs = true;
    }
    let suffix = ''
    let idx = pathname.lastIndexOf('.');
    if (idx >= 0) {
        suffix = pathname.substring(idx).toLowerCase()
    }

    let contentType = Vue2Loader.detectContentTypeBySuffix(suffix)

    if (contentType && contentType.indexOf('charset') < 0) {
        contentType = `${contentType}; charset=utf-8`;
    } else {
        contentType = `application/octet-stream`;
    }
    return new Promise(function (resolve, reject) {
        let callbackFunctionName = options.callbackFunctionName || 'jsonp_callback'
        if (options.randomCallbackFunctionName) {
            callbackFunctionName = callbackFunctionName + '_' + Vue2Loader.randomUUID()
        }
        if (callbackFunctionName == 'jsonp_callback' && isJsonpJs) {
            let maxTryTime=30000;
            let sleepTs=30;
            let tryCount=maxTryTime/sleepTs;
            let urlPath=new URL(url,window.location.href).pathname;
            let tryTask=()=>{
                for (let i = 0; i < Vue2Loader._jsonpResources.length; i++) {
                    let item=Vue2Loader._jsonpResources[i]
                    if(urlPath.endsWith(item.path)){
                        let payload=item.payload;
                        if (typeof payload != 'string') {
                            try {
                                payload = JSON.stringify(payload)
                            } catch (e) {
                                payload = payload + '';
                            }
                        }
                        resolve(new Response(payload, {
                            status: 200,
                            statusText: "OK",
                            headers: {
                                // 强烈建议加上 Content-Type，方便下游的 .json() 或 .text() 方法正确解析
                                'Content-Type': contentType
                            }
                        }))
                        return
                    }
                }
                tryCount--;
                if(tryCount>0){
                    setTimeout(()=>{
                        tryTask()
                    },30)
                }else{
                    let text = '404, Jsonp Not Found';
                    reject(new Response(text, {
                        status: 404,
                        statusText: "404 Jsonp Not Found",
                        headers: {
                            'Content-Type': `text/html; charset=utf-8`
                        }
                    }))
                }
            }
            tryTask()
        }else {
        window[callbackFunctionName] = function (response) {
                let payload = response;
                if (typeof payload != 'string') {
                    try {
                        payload = JSON.stringify(payload)
                    } catch (e) {
                        payload = payload + '';
                    }
                }
                resolve(new Response(payload, {
                    status: 200,
                    statusText: "OK",
                    headers: {
                        // 强烈建议加上 Content-Type，方便下游的 .json() 或 .text() 方法正确解析
                        'Content-Type': contentType
                    }
                }))

        }
        }

        let src = url + ''
        if (src.indexOf('?') >= 0) {
            src += '&'
        } else {
            src += '?'
        }
        src += 'jsonp_callback=' + callbackFunctionName

        let jsonpScriptId = 'jsonp_script_' + Vue2Loader.randomUUID()
        let scriptDom = document.createElement('script')
        scriptDom.id = jsonpScriptId
        scriptDom.src = src
        scriptDom.charset = 'UTF-8'
        scriptDom.nonce = jsonpScriptId
        if (options.referrerPolicy) {
            scriptDom.referrerPolicy = options.referrerPolicy // 'same-origin'
        }
        if (options.crossOrigin) {
            scriptDom.crossOrigin = options.crossOrigin // 'true'
        }

        scriptDom.onerror = function (event, source, lineno, colno, error) {
            reject({
                message: '400, Jsonp Error',
                event: event,
                source: source,
                lineno: lineno,
                colno: colno,
                error: error
            })
        }

        Vue2Loader.domAppend(document.body, scriptDom)

        let timeout = options.timeout || -1

        setTimeout(function () {
            if (timeout > 0) {
                reject(new Error('fetch jsonp timeout of ' + timeout + '!'))
            }
            Vue2Loader.domRemove(scriptDom)
        }, timeout > 0 ? timeout : 1500)
    })
}


/**
 *
 * @param url {string}
 * @return {Promise<string>}
 */
Vue2Loader.fetchUrl = function (url) {
    if (url) {
        let idx = url.lastIndexOf('?')
        if (idx >= 0) {
            url = url + '&'
        } else {
            url = url + '?'
        }
        // 允许30s的缓存
        url = url + '_tc=' + Math.floor(new Date().getTime() / 1000 / 30)
    }
    // fetch resource chain
    return Promise.reject({
        ok: false,
        value: undefined
    })
        .catch(function (err) {
            // use fetch
            let href = url
            let workFetch = window.fetch;
            if ((typeof originFetch) !== 'undefined') {
                workFetch = originFetch;
            }
            if ((typeof workFetch) !== 'undefined') {
                return workFetch(href, {
                    mode: 'no-cors'
                }).then(function (res) {
                    if (res.status != 200) {
                        return res.text().then(function (text) {
                            return Promise.reject({
                                ok: false,
                                value: text
                            })
                        })
                    }
                    return res.text()
                }).then(function (text) {
                    if (!text || text == '') {
                        return Promise.reject({
                            ok: true,
                            value: text
                        })
                    }
                    return text
                })
            } else {
                if (err.ok === true) {
                    return Promise.reject(err)
                } else {
                    return Promise.reject({
                        ok: false,
                        value: undefined
                    })
                }
            }
        })
        .catch(function (err) {
            // use xhr
            let href = url
            if ((typeof XMLHttpRequest) !== 'undefined') {
                return Vue2Loader.fetchXhr(href)
                    .then(function (text) {
                        if (!text || text == '') {
                            return Promise.reject({
                                ok: true,
                                value: text
                            })
                        }
                        return text
                    })
            } else {
                if (err.ok === true) {
                    return Promise.reject(err)
                } else {
                    return Promise.reject({
                        ok: false,
                        value: undefined
                    })
                }
            }
        })
        .catch(function (err) {
            // use axios
            let href = url
            if ((typeof axios) !== 'undefined') {
                return axios({
                    url: href,
                    method: 'get',
                    responseType: 'text'
                }).then(function (res) {
                    let text = res.data
                    if (!text || text == '') {
                        return Promise.reject({
                            ok: true,
                            value: text
                        })
                    }
                    return text
                })
            } else {
                if (err.ok === true) {
                    return Promise.reject(err)
                } else {
                    return Promise.reject({
                        ok: false,
                        value: undefined
                    })
                }
            }
        }).catch(function (err) {
            // use jsonp
            let href = url
            if (window.location.protocol === 'file:') {
                let idx = href.lastIndexOf('?')
                if (idx >= 0) {
                    href = href.substring(0, idx) + '.jsonp.js' + href.substring(idx)
                } else {
                    href = href + '.jsonp.js'
                }
                return Vue2Loader.fetchJsonp(href)
                    .then(function (res) {
                        return res.text()
                    }).then(function (text) {
                        if (!text || text == '') {
                            return Promise.reject({
                                ok: true,
                                value: text
                            })
                        }
                        return text
                    })
            } else {
                if (err.ok === true) {
                    return Promise.reject(err)
                } else {
                    return Promise.reject({
                        ok: false,
                        value: undefined
                    })
                }
            }
        }).catch(function (err) {
            // use iframe
            let href = url
            let idx = href.lastIndexOf('?')
            if (idx >= 0) {
                href = href.substring(0, idx) + '.iframe.txt' + href.substring(idx)
            } else {
                href = href + '.iframe.txt'
            }
            return Vue2Loader.fetchIframe(href)
                .then(function (res) {
                    return res.text()
                }).then(function (text) {
                    if (!text || text == '') {
                        return Promise.reject({
                            ok: true,
                            value: text
                        })
                    }
                    return text
                }).catch(function (innerErr) {
                    if (err.ok === true) {
                        return Promise.reject(err)
                    } else {
                        return Promise.reject({
                            ok: false,
                            value: undefined
                        })
                    }
                })
        }).catch(function (err) {
            if (new URL(url, window.location.href).protocol === 'file:') {
                return Vue2Loader.fetchFile(url)
                    .then(function (res) {
                        if (res.status != 200) {
                            return res.text().then(function (text) {
                                return Promise.reject({
                                    ok: false,
                                    value: text
                                })
                            })
                        }
                        return res.text()
                    })
            } else {
                return Promise.reject({
                    ok: false,
                    value: undefined
                })
            }
        }).catch(function (err) {
            // process possible value
            if (err.ok === true) {
                return Promise.resolve(err.value)
            } else {
                return Promise.reject(err)
            }
        })

}

/**
 * @type {FileSystemItem}
 * @constructor {FileSystemItem}
 * @return {FileSystemItem}
 */
function FileSystemItem() {
    /**
     * @type {string|null}
     */
    this.name = null;
    /**
     * @type {FileSystemHandle|null}
     */
    this.handle = null;
    /**
     * @type {string|null}
     */
    this.path = null;
    /**
     * @type {string|null}
     */
    this.parentPath = null;
    /**
     * @type {FileSystemDirectoryHandle|null}
     */
    this.parent = null;
    /**
     * @type {File|null}
     */
    this.file = null;
    /**
     * @type {boolean}
     */
    this.isFile = false;
}

/**
 * get local filesystem directory handle
 *
 * @return {Promise<FileSystemDirectoryHandle>}
 */
Vue2Loader.getDirectoryHandle = function () {
    return showDirectoryPicker({
        mode: 'read',
        startIn: 'desktop',
        id: 'project_home'
    })
}

/**
 * tree dirPath files
 *
 * @param rootDirHandle {FileSystemDirectoryHandle}
 * @param dirPath {string|null}
 * @returns {Promise<FileSystemItem[]>}
 */
Vue2Loader.scanFilesMappingNext = async function (rootDirHandle, dirPath) {
    /**
     * @type {FileSystemItem[]}
     */
    let ret = []
    if (!rootDirHandle) {
        return ret
    }
    if (!dirPath) {
        dirPath = ''
    }
    for await (const [name, handle] of rootDirHandle.entries()) {

        let item = new FileSystemItem()
        item.name = name
        item.handle = handle
        item.path = dirPath + '/' + name
        item.parentPath = dirPath
        item.parent = rootDirHandle
        item.file = null
        item.isFile = false


        ret.push(item)

        if (handle.kind === 'file') {
            item.isFile = true
            item.file = await item.handle.getFile()
        } else {
            let next = await Vue2Loader.scanFilesMappingNext(handle, item.path)
            ret.push(...next)
        }
    }
    return ret
}

/**
 * @type {FileLoaderItem}
 * @constructor {FileLoaderItem}
 * @return {FileLoaderItem}
 */
function FileLoaderItem() {
    /**
     *
     * @type {FileSystemDirectoryHandle}
     */
    this.dirHandle = null;

    /**
     *
     * @type {FileSystemItem[]|null}
     */
    this.files = null;
}


/**
 *
 * @type {Map<string, FileLoaderItem>}
 * @private
 */
Vue2Loader._fileLoaderCache = new Map();

Vue2Loader._fileLoaderQueue={}

Vue2Loader.getFileLoader = function (callUrl) {
    if (!callUrl) {
        callUrl = window.location.pathname;
    } else {
        callUrl = new URL(callUrl, window.location.href).pathname;
    }
    return new Promise((resolve,reject)=>{
        let promise={
            resolve: resolve,
            reject: reject
        }
        Vue2Loader._fileLoaderQueue[callUrl]=[...(Vue2Loader._fileLoaderQueue[callUrl] || []),promise]
    })
}

Vue2Loader.fileLoaderQueueTask=function(){
    let keys=Object.keys(Vue2Loader._fileLoaderQueue);
    if(keys.length>0){
        let curKey=keys[0];
        if(Vue2Loader._fileLoaderQueue[curKey] && Vue2Loader._fileLoaderQueue[curKey].length>0){
            let processList=Vue2Loader._fileLoaderQueue[curKey].splice(0,Vue2Loader._fileLoaderQueue[curKey].length)
            Vue2Loader.getFileLoader0(curKey)
                .then(resp=>{
                    processList.forEach(e=>{
                        e.resolve(resp)
                    })
                }).catch(err=>{
                processList.forEach(e=>{
                    e.reject(err)
                })
                }).finally(()=>{
                    setTimeout(function(){
                        Vue2Loader.fileLoaderQueueTask()
                    },300)
                })
            return
        }

    }
    setTimeout(function(){
        Vue2Loader.fileLoaderQueueTask()
    },300)
}

setTimeout(function(){
    Vue2Loader.fileLoaderQueueTask()
},300)

/**
 *
 * @param callUrl {string|null}
 * @returns {Promise<FileLoaderItem>}
 */
Vue2Loader.getFileLoader0 = function (callUrl) {
    if (!callUrl) {
        callUrl = window.location.pathname;
    } else {
        callUrl = new URL(callUrl, window.location.href).pathname;
    }

    return new Promise(function (resolve, reject) {
        if (Vue2Loader._fileLoaderCache[callUrl]) {
            resolve(Vue2Loader._fileLoaderCache[callUrl])
            return
        }

        let sysPath=callUrl;
        if(/^\/[a-zA-Z]:\//.test(sysPath)){
            sysPath=sysPath.substring(1);
        }
        if(!sysPath.endsWith('/')){
            let idx=sysPath.lastIndexOf('/');
            if(idx>=0){
                sysPath=sysPath.substring(0,idx);
            }
        }

        let userActionDom = document.createElement('div');
        userActionDom.innerHTML = '请点击此处，复制路径，开始选择此文件所在路径<br/>如果不选择，请使用convertor转换项目<br/>' + callUrl;
        userActionDom.style.position = 'fixed';
        userActionDom.style.left = '50%';
        userActionDom.style.top = '50%';
        userActionDom.style.transform = 'translate(-50%, -50%)';
        userActionDom.style.minWidth = '480px';
        userActionDom.style.width = '60%';
        userActionDom.style.height = '240px';
        userActionDom.style.background = 'white';
        userActionDom.style.textAlign = 'center';
        userActionDom.style.display = 'flex';
        userActionDom.style.alignItems = 'center';
        userActionDom.style.justifyContent = 'center';
        userActionDom.style.padding = '12px';
        userActionDom.style.borderRadius = '12px';
        userActionDom.style.boxShadow = '3px 3px 8px #777';
        userActionDom.style.color = 'orangered';

        document.body.appendChild(userActionDom);
        userActionDom.onclick = function () {
            document.body.removeChild(userActionDom)

            Vue2Loader.copyToClipboard(sysPath);

            Vue2Loader.getDirectoryHandle()
                .then(async function (handle) {
                    let arr = await Vue2Loader.scanFilesMappingNext(handle)

                    let item = new FileLoaderItem();
                    item.dirHandle = handle;
                    item.files = arr;

                    Vue2Loader._fileLoaderCache[callUrl] = item;
                    resolve(item)
                }).catch(function (err) {
                reject(err)
            })
        }


    })

}

/**
 * notify counter
 *
 * @type {number}
 * @private
 */
Vue2Loader._notifyCount=0;

/**
 * show an notify popup
 *
 * @param content {string}
 * @param level {'primary'|'info'|'warning'|'danger'|'success'|null|undefined}
 */
Vue2Loader.notify=function(content,level){
    if(!level){
        level='primary'
    }
    let levelColor='dodgerblue'
    if(level=='primary'){
        levelColor='dodgerblue'
    }else if(level=='info'){
        levelColor='#777'
    }else if(level=='warning'){
        levelColor='orange'
    }else if(level=='danger'){
        levelColor='red'
    }else if(level=='success'){
        levelColor='limegreen'
    }
    let notifyDom = document.createElement('div');
    notifyDom.innerHTML = content;
    notifyDom.style.position = 'fixed';
    notifyDom.style.right = '-5%';
    notifyDom.style.top = Math.min(90,5*Math.max(1,Vue2Loader._notifyCount+1))+'%';
    notifyDom.style.minWidth = '120px';
    notifyDom.style.minHeight = '60px';
    notifyDom.style.background = 'white';
    notifyDom.style.textAlign = 'center';
    notifyDom.style.display='flex';
    notifyDom.style.alignItems = 'center';
    notifyDom.style.justifyContent = 'center';
    notifyDom.style.padding = '8px';
    notifyDom.style.borderRadius = '8px';
    notifyDom.style.boxShadow = `3px 3px 8px ${levelColor}`;
    notifyDom.style.color = levelColor;
    notifyDom.style.transition='right 0.4s cubic-bezier(0.25, 0.8, 0.25, 1)';

    Vue2Loader._notifyCount=Math.max(0,Vue2Loader._notifyCount)+1;
    document.body.appendChild(notifyDom);

    requestAnimationFrame(() => {
        notifyDom.style.right = '5%';
    });

    setTimeout(function(){
        document.body.removeChild(notifyDom);
        Vue2Loader._notifyCount--;
    },5000)
}

Vue2Loader.notify.info=function(content){
    Vue2Loader.notify(content,'info')
}

Vue2Loader.notify.warning=function(content){
    Vue2Loader.notify(content,'warning')
}

Vue2Loader.notify.danger=function(content){
    Vue2Loader.notify(content,'danger')
}

Vue2Loader.notify.success=function(content){
    Vue2Loader.notify(content,'success')
}

Vue2Loader.notify.primary=function(content){
    Vue2Loader.notify(content,'primary')
}

Vue2Loader.copyToClipboard= function (text) {
    let ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    try {
        document.execCommand('copy');
        Vue2Loader.notify.success('复制成功')
    } catch (e) {
        Vue2Loader.notify.warning('复制失败')
    }
    document.body.removeChild(ta);
}

/**
 * fetch url resource in local filesystem
 * response adaptable `fetch.then`
 *
 * @param url {string}
 * @returns {Promise<Response>}
 */
Vue2Loader.fetchFile = function (url) {
    return Vue2Loader.getFileLoader()
        .then(async fileLoader => {
            let arr = fileLoader.files

            let htmlPath = new URL(window.location.href).pathname;
            let resPath = new URL(url, window.location.href).pathname;

            let rootPath = htmlPath;
            let idx = htmlPath.lastIndexOf('/');
            if (idx >= 0) {
                rootPath = htmlPath.substring(0, idx);
            }

            resPath = resPath.substring(rootPath.length);

            let fileItems = arr.filter(e => e.path == resPath);

            let contentType = 'text/html';

            if (!fileItems || fileItems.length == 0) {
                let text = '404, Not Found';
                return new Response(text, {
                    status: 404,
                    statusText: "404 Not Found",
                    headers: {
                        'Content-Type': `${contentType}; charset=utf-8`
                    }
                });
            }

            let suffix = ''
            idx = resPath.lastIndexOf('.');
            if (idx >= 0) {
                suffix = resPath.substring(idx).toLowerCase()
            }

            contentType = Vue2Loader.detectContentTypeBySuffix(suffix)

            if (contentType && contentType.indexOf('charset') < 0) {
                contentType = `${contentType}; charset=utf-8`;
            } else {
                contentType = `application/octet-stream`;
            }

            let fileItem = fileItems[0]
            let file = fileItem.file;

            return new Response(fileItem.file, {
                status: 200,
                statusText: "OK",
                headers: {
                    // 强烈建议加上 Content-Type，方便下游的 .json() 或 .text() 方法正确解析
                    'Content-Type': contentType,
                    'Content-Length': file.size
                }
            });
        })
}

/**
 *
 * @param suffix {string}
 * @returns {string|null}
 */
Vue2Loader.detectContentTypeBySuffix = function (suffix) {
    let contentType = Vue2Loader._SUFFIX_MIME_TYPE_MAP[suffix] || null
    return contentType
}

/**
 * store origin window.fetch
 *
 * @type {(input: (RequestInfo | URL), init?: RequestInit) => Promise<Response>}
 */
const originFetch = window.fetch;

/**
 * bind to type
 *
 * @type {function((RequestInfo|URL), RequestInit=): Promise<Response>}
 */
Vue2Loader.originFetch = originFetch;

/**
 * adapt for local filesystem
 *
 * @param url {string|URL|RequestInfo}
 * @param config {RequestInit|undefined}
 * @returns {Promise<Response>}
 */
Vue2Loader.resourceFetch = function (url, config) {
    if (window.location.protocol === 'file:') {
        return Promise.reject(false)
            .catch(err => {
                let href = url
                let idx = href.lastIndexOf('?')
                if (idx >= 0) {
                    href = href.substring(0, idx) + '.jsonp.js' + href.substring(idx)
                } else {
                    href = href + '.jsonp.js'
                }
                return Vue2Loader.fetchJsonp(href)
            }).catch(err => {
                let href = url
                let idx = href.lastIndexOf('?')
                if (idx >= 0) {
                    href = href.substring(0, idx) + '.iframe.txt' + href.substring(idx)
                } else {
                    href = href + '.iframe.txt'
                }
                return Vue2Loader.fetchIframe(href)
            }).catch(err => {
                return Vue2Loader.fetchFile(url)
                    .then(function (res) {
                        if (res.status != 200) {
                            return Promise.reject(res)
                        }
                        return res.text()
                    })
            })
            .catch(err => {
                return originFetch(url, config)
            })
    } else {
        return originFetch(url, config)
    }
}

window.fetch=Vue2Loader.resourceFetch;

/**
 *
 * @param header {string} html of head segment
 */
Vue2Loader.appendHeader = function (header) {
    if (header && header != '') {
        document.head.innerHTML = document.head.innerHTML + header
        let arr = document.head.querySelectorAll('title')
        for (let i = 0; i < arr.length; i++) {
            if (i != arr.length - 1) {
                Vue2Loader.domRemove(arr[i])
            }
        }
    }
}

/**
 * 从URL中加载export default {}导出的对象进行返回
 * @param url {string} js导出文件的路径，一般为xxx.js
 * @return {Promise<Object | null>} 导出的对象
 */
Vue2Loader.loadObject = function (url) {
    return Vue2Loader.fetchUrl(url)
        .then(function (script) {
            let varName = 'js_obj_' + Vue2Loader.randomUUID()
            script = script.replace(/export\s+default\s+\{/, 'window.' + varName + ' = {')
            let scriptDom = Vue2Loader.domGetOrCreate('js_obj_script_' + varName, 'script', document.body);
            scriptDom.type = 'text/javascript'
            Vue2Loader.domSetInnerHtml(scriptDom, script)
            return new Promise(function (resolve, reject) {
                let spyAppSetupCall = function () {
                    if (window[varName]) {
                        resolve(window[varName])
                        setTimeout(function () {
                            delete window[varName]
                            Vue2Loader.domRemove(scriptDom)
                        }, 500)
                    } else {
                        setTimeout(spyAppSetupCall, 30)
                    }
                }
                setTimeout(spyAppSetupCall, 30)
            })
        }).catch(function (err) {
            console.warn('load object failure!', url)
            return Promise.resolve(null)
        })
}

/**
 * 将.vue文件的文本转换为一个对象
 * 用于后续处理
 * @param html {string} 内容就是.vue文件的文本
 * @return {{template: string, varName: string, header: string, style: string, script: string}}
 */
Vue2Loader.parseVueTemplate = function (html) {
    let sfc = parseVueSFC(html);
    let template = sfc.template;

    // 处理 scoped class样式
    let className = 'vue-scoped-style-' + Vue2Loader.randomUUID().toLowerCase();
    let rootTagMatched = template.match(/^\s*<[^>]*>/);
    if (rootTagMatched) {
        let rootTag = rootTagMatched[0];
        let leftTemplate = template.substring(rootTag.length);

        let classPart = rootTag.match(/class\s*=\s*('[^']*'|"[^"]*")/);
        if (classPart) {
            let matchedAttr = classPart[0];

            let matchedAttrValue = classPart[1];

            let fullClassName = matchedAttrValue;
            let encloseChar = '"';
            if (fullClassName.startsWith("'")) {
                encloseChar = "'";
            }
            fullClassName = fullClassName.substring(1, fullClassName.length - 1);

            fullClassName = fullClassName + " " + className;

            let newAttrValue = encloseChar + fullClassName + encloseChar;
            let newAttr = matchedAttr.replace(matchedAttrValue, newAttrValue);
            rootTag = rootTag.replace(matchedAttr, newAttr)
        } else {
            let encloseChar = '"';
            let fullClassName = className;
            let newAttrValue = encloseChar + fullClassName + encloseChar;
            let newAttr = "class=" + newAttrValue;
            rootTag = rootTag.replace(/>$/, ' ' + newAttr + '>');
        }
        template = rootTag + leftTemplate;
    }

    let script = sfc.script;
    let varName = 'vue_conf_' + Vue2Loader.randomUUID()
    script = script.replace(/export\s+default\s+\{/, 'let ' + varName + ' = {')

    let style = sfc.style;
    style = style.replace('.--this', ('.' + className))

    let header = sfc.header;

    return {
        template: template,
        script: script,
        style: style,
        header: header,
        varName: varName
    }
}

/**
 * 通过给定的url指定的.vue文件，构建一个包含template的Vue组件options对象
 * @param url vue文件的URL，一般为xxx.vue
 * @returns {Promise<Object>} vue组件的Options,可用于Vue.component(name,options)等场景用于组件注册
 */
Vue2Loader.loadVueOptions = function (url) {
    let appId = 'vue_' + Vue2Loader.randomUUID()
    return new Promise(function (resolve, reject) {
        Vue2Loader.fetchUrl(url)
            .then(function (html) {
                let vueTemplate = Vue2Loader.parseVueTemplate(html)
                // 挂载到全局变量上
                window['vue_component_' + appId] = vueTemplate.template;


                let styleDom = Vue2Loader.domGetOrCreate('vue_component_style_' + appId, 'style', document.body);
                Vue2Loader.domSetInnerHtml(styleDom, vueTemplate.style)


                let vueCompVarName = 'vue_comp_' + vueTemplate.varName
                let script = vueTemplate.script
                script += '\n'
                script += 'Vue2Loader.evalVueComponent(' + vueTemplate.varName + ',"' + appId + '","' + vueCompVarName + '")\n'

                let scriptDom = Vue2Loader.domGetOrCreate('vue_component_script_' + appId, 'script', document.body);
                scriptDom.type = 'text/javascript'
                Vue2Loader.domSetInnerHtml(scriptDom, script)

                let spyCompSetupCall = function () {
                    if (window[vueCompVarName]) {
                        Vue2Loader.domRemove(scriptDom)
                        resolve(window[vueCompVarName])
                        setTimeout(function () {
                            delete window[vueCompVarName]
                        }, 300)
                    } else {
                        setTimeout(spyCompSetupCall, 30)
                    }
                }
                setTimeout(spyCompSetupCall, 30)
            }).catch(function (error) {
            console.warn('load vue options failure!', url)
            reject(error)
        })
    })

}

/**
 * 内部使用，
 * 用于将loadVueOptions而来的vue文本转换为一个完整的VueOptions
 * 提供给后续的构建Vue组件等提供帮助
 * 主要是将.vue中template的元素转换为vueOptions.template属性
 * 以便于进行局部注册或者其他使用
 * @param vueOptions 未完善的VueOptions对象，或者.vue文件中export default{}的默认对象
 * @param templateElemId 模版元素ID，临时的ID，需要唯一
 * @param vueCompVarName 全局组件变量名，也是临时的，需要唯一
 */
Vue2Loader.evalVueComponent = function (vueOptions,
                                        templateElemId,
                                        vueCompVarName) {
    // 从挂载变量上获取模版
    vueOptions.template = window['vue_component_' + templateElemId];
    delete window['vue_component_' + templateElemId];

    window[vueCompVarName] = vueOptions
}

/**
 * 通过URL对.vue文件加载处理为一个VueOptions
 * 实际是使用URL中export default {} 的对象作为指定的options
 * Vue.extend(options)
 * @param url 指定的options连接，一般为xxx.vue文件，文件中包含唯一的一个export default {}语法
 * @returns {Promise<Object>} Vue.extend(options)出来的对象
 */
Vue2Loader.loadVueComponent = function (url) {
    return new Promise(function (resolve, reject) {
        Vue2Loader.loadVueOptions(url)
            .then(function (vueOptions) {
                let nextHref = new URL(url, window.location.href).href
                Vue2Loader.resolveVueDependency(vueOptions, nextHref)
                    .then(function (resolveOptions) {
                        let comps = Vue.extend(resolveOptions)
                        resolve(comps)
                    }).catch(function (error) {
                    console.warn('resolve component dependency failure!', nextHref)
                    let comps = Vue.extend(vueOptions)
                    resolve(comps)
                })
            }).catch(function (error) {
            console.warn('load vue component failure!', url)
            reject(error)
        })
    })
}

/**
 * 通过URL将组件componentName全局注册到Vue中
 * 实际是使用URL中export default {} 的对象作为指定的options
 * Vue.component(directiveName,options)
 * @param url 指定的options连接，一般为xxx.vue文件，文件中包含唯一的一个export default {}语法
 * @param componentName 组件名称
 * @returns {Promise<Object>} Vue.component(name,options)出来的对象
 */
Vue2Loader.registryVueComponent = function (url, componentName = null) {
    return new Promise(function (resolve, reject) {
        Vue2Loader.loadVueOptions(url)
            .then(function (vueOptions) {
                let nextHref = new URL(url, window.location.href).href
                Vue2Loader.resolveVueDependency(vueOptions, nextHref)
                    .then(function (resolveOptions) {
                        let comps = Vue.component(componentName || resolveOptions.name, resolveOptions)
                        resolve(comps)
                    }).catch(function (error) {
                    console.warn('registry component dependency failure!', nextHref)
                    let comps = Vue.component(componentName || vueOptions.name, vueOptions)
                    resolve(comps)
                })
            }).catch(function (error) {
            console.warn('registry vue component failure!', url)
            reject(error)
        })
    })
}

/**
 * 通过URL将指令directiveName注册到Vue中
 * 实际是使用URL中export default {} 的对象作为指定的options
 * Vue.directive(directiveName,options)
 * @param url 指定的options连接，一般为xxx.js文件，文件中包含唯一的一个export default {}语法
 * @param directiveName 指令名称
 * @returns {Promise<Object>} Vue.directive(name,options)出来的对象
 */
Vue2Loader.registryVueDirective = function (url, directiveName = null) {
    return new Promise(function (resolve, reject) {
        Vue2Loader.loadVueOptions(url)
            .then(function (vueOptions) {
                let nextHref = new URL(url, window.location.href).href
                Vue2Loader.resolveVueDependency(vueOptions, nextHref)
                    .then(function (resolveOptions) {
                        let comps = Vue.directive(directiveName || resolveOptions.name, resolveOptions)
                        resolve(comps)
                    }).catch(function (error) {
                    console.warn('registry directive dependency failure!', nextHref)
                    let comps = Vue.directive(directiveName || vueOptions.name, vueOptions)
                    resolve(comps)
                })
            }).catch(function (error) {
            console.warn('registry vue directive failure!', url)
            reject(error)
        })
    })
}

/**
 * 使用url指定的.vue文件进行Vue渲染到domId的元素上
 * 使用.vue文件创建网页
 * 支持简单的.vue文件内容
 * template,script,style
 * 区别是，使用相对连接指定components,mixins,directives
 * 具体可参考resolveVueDependency的vueOptions内容
 * 使用案例：
 * test.html
 * ************************************************
 * <!DOCTYPE html>
 * <html>
 * <head>
 *     <meta charset="UTF-8">
 *     <title>vue2</title>
 *     <script src="../vue@2_dist_vue.js"></script>
 *     <script src="../Vue2Loader.js"></script>
 * </head>
 * <body>
 *    <div id="app">
 *    </div>
 * </body>
 * <script>
 *
 * Vue2Loader.createVue('./components/app.vue','#app')
 *
 * </script>
 * <style>
 *
 * </style>
 * </html>
 * ************************************************
 * app.vue
 * ************************************************
 * <template>
 *   <div class="app">
 *     {{message}}
 *     <span>world</span>
 *     <comp></comp>
 *     <hr/>
 *     <reso></reso>
 *   </div>
 * </template>
 *
 * <header>
 *   <title>加油</title>
 * </header>
 *
 * <script>
 * export default {
 *   name: "test",
 *   title: '测试页面',
 *   components:{
 *     comp: './comp/comp.vue',
 *     reso: './comp/reso/reso.vue'
 *   },
 *   mixins:['../mixins/mixin.js'],
 *   data(){
 *     return {
 *       message: 'hello'
 *     }
 *   },
 *   created(){
 *     this.alertHello()
 *   }
 * }
 * </script>
 *
 * <style scoped>
 * .app{
 *   color: blue;
 * }
 * .--this{
 *   background: lightseagreen;
 * }
 * .--this span{
 *   color: coral;
 * }
 * span{
 *   color: cyan;
 * }
 * </style>
 * ************************************************
 * 案例解析
 * test.html是HTML文件，是入口文件
 *
 * 添加了必要的script脚本vue和Vue2Loader
 * <script src="../vue@2_dist_vue.js"></script>
 * <script src="../Vue2Loader.js"></script>
 *
 * 在body中定义了Vue进行mount的根元素#app
 * <body>
 *    <div id="app">
 *    </div>
 * </body>
 *
 * 使用Vue2Loader加载指定的app.vue绑定到#app元素上进行Vue渲染
 * <script>
 * Vue2Loader.createVue('./components/app.vue','#app')
 * </script>
 *
 * app.vue就是使用vue-cli构建是的vue文件
 * 内容和语法上大体相似
 * 区别在于，不能使用import
 * 只能使用export default {}语法
 * 不能export其他对象
 *
 * 允许使用header标签，将自定义的HTML的head内容添加到HTML中
 * <header>
 *   <title>加油</title>
 * </header>
 *
 * 在VueOptions中允许使用title指定页面的标题
 * title: '测试页面',
 *
 * 通过URL加载方式，实现组件导入与混入导入等特性
 * 这部分具体参考Vue2Loader.resolveVueDependency的注释讲解
 * components:{
 *   comp: './comp/comp.vue',
 *   reso: './comp/reso/reso.vue'
 * },
 * mixins:['../mixins/mixin.js'],
 *
 * 加载器不会处理scoped
 * <style scoped>
 * </style>
 *
 * 但是允许在style中使用[.--this]来限定为根元素的类名
 * 这样也能够达到一部分的scoped的特性，限制用于根元素下的类样式
 * .--this{
 *   background: lightseagreen;
 * }
 * .--this span{
 *   color: coral;
 * }
 *
 * @param url 用于构建的.vue文件的URL，一般为xxx.vue
 * @param domId 绑定Vue进行渲染的元素ID，若查找不到元素，将会创建一个此ID的元素到body中,默认为app
 * @return {Promise<Object>} new Vue(options)出来的对象
 */
Vue2Loader.createVue = function (url, domId = 'app') {
    Vue2Loader.domGetOrCreate(domId, 'div', document.body)
    return new Promise(function (resolve, reject) {
        Vue2Loader.loadVueOptions(url)
            .then(function (vueOptions) {
                let nextHref = new URL(url, window.location.href).href
                Vue2Loader.resolveVueDependency(vueOptions, nextHref)
                    .then(function (resolveOptions) {
                        resolveOptions.el = '#' + domId
                        let app = new Vue(resolveOptions)
                        resolve(app)
                    }).catch(function (error) {
                    console.warn('resolve component dependency failure!', nextHref)
                    vueOptions.el = '#' + domId
                    let app = new Vue(vueOptions)
                    resolve(app)
                })
            }).catch(function (error) {
            console.warn('create vue failure!', url)
            reject(error)
        })
    })
}

/**
 * mixin loader helper methods to vue options
 *
 * @param vueOptions {object}
 * @param baseHref {string}
 * @return {void}
 */
Vue2Loader.mixinLoaderMethodsToVueOptions=function(vueOptions,baseHref){
    vueOptions.methods={
        ...vueOptions.methods,
        /**
         * 返回组件本身的地址
         *
         * @return {string}
         */
        loaderHref(){
            return baseHref;
        },
        /**
         * 返回相对于组件的真实地址
         *
         * @param url 相对与组件的地址
         * @return {string}
         */
        loaderUrl(url){
            return new URL(url,this.loaderHref()).href;
        },
        /**
         * 返回相对于组件的真实地址对应的资源
         *
         * @param url 相对与组件的地址
         * @return {Promise<Response>}
         */
        loaderResource(url){
            return fetch(this.loaderUrl(url))
        }
    }
}

/**
 * 递归解析VueOptions中的属性
 * baseHref用于记录传入的VueOptions对应的基本URL路径，进行递归查找依赖时，才能确定真实的URL绝对路径进行加载依赖
 * 将器加载为真实的对象
 * 处理
 * vueOptions.components 将会使用真实对象替换URL指向，实现局部组件注册
 * vueOptions.mixins 将会使用真实对象替换URL指向，实现局部混入
 * vueOptions.directives 将会直接进行Vue.directive指令注册
 * vueOptions.objects 将会将对象都挂载到Vue.prototype原型上
 * vueOptions.methods 添加几个个固定的方法，用于解析相对于组件的资源地址，详情查看 `Vue2Loader.mixinLoaderMethodsToVueOptions` 实现
 * 使用案例:
 * ************************************************
 * vueOptions={
 *     components:{
 *         test: './test.vue',
 *         comp: './components/comp.vue',
 *         parent: '../parent.vue'
 *     },
 *     mixins:['./common.js','./mixins/list.js'],
 *     directives:{
 *         show: './directives/show.js',
 *         hover: '../common/hover-directive.js'
 *     },
 *     objects:{
 *         rsa: '../util/rsa.js'
 *     },
 *     // ...
 *     // 以下是vue其他的配置,区别是上面这部分的写法
 *     data(){
 *         return {
 *              sampleText: ''
 *         }
 *     },
 *     mounted(){
 *
 *     },
 *     created(){
 *          this.sampleFetch();
 *     },
 *     methods:{
 *          sampleFetch(){
 *              // 使用注入的loaderUrl解析相对于组件的相对地址
 *              // 这样才能拿到真实的地址
 *              // 否则，直接使用fetch的话，这个应该是相对于html文件的地址
 *              // 而不是相对于组件的地址
 *              // loaderUrl 的作用就是解析为真实的地址
 *              let url=this.loaderUrl('./sample.txt')
 *              fetch(url).then(r=>r.text()).then(t=>{
 *                  this.sampleText=t;
 *              })
 *          }
 *     }
 *
 * }
 * ************************************************
 * 案例解析
 * components注册了test,comp,parent三个组件
 * mixins混入了两个特性
 * directives注册了show,hover两个全局指令
 * objects将rsa挂载到了Vue.prototype上，得到Vue.prototype.rsa
 * @param vueOptions Vue的Options对象
 * @param baseHref 传入的vueOptions对应的绝对路径，用于处理递归的依赖的绝对路径
 * @return {Promise<Object>} 处理替换完整的VueOptions,引用还是传入的vueOptions
 */
Vue2Loader.resolveVueDependency = function (vueOptions, baseHref) {
    Vue2Loader.mixinLoaderMethodsToVueOptions(vueOptions,baseHref)

    let arr = []
    if (vueOptions.components) {
        Object.keys(vueOptions.components).forEach(function (key) {
            let value = vueOptions.components[key]
            if (typeof value === 'string') {
                arr.push(new Promise(function (res, rej) {
                    let nextHref = new URL(value, baseHref).href
                    Vue2Loader.loadVueOptions(nextHref)
                        .then(function (comp) {
                            Vue2Loader.resolveVueDependency(comp, nextHref)
                                .then(function (comOptions) {
                                    vueOptions.components[key] = Vue.extend(comOptions)
                                    res(true)
                                }).catch(function (err) {
                                console.warn('resolve component dependency failure!', nextHref)
                                vueOptions.components[key] = Vue.extend(comOptions)
                                res(true)
                            })
                        }).catch(function (err) {
                        console.warn('load component failure!', nextHref)
                        rej(false)
                    })
                }))
            }
        })
    }
    if (vueOptions.mixins) {
        for (let i = 0; i < vueOptions.mixins.length; i++) {
            let value = vueOptions.mixins[i]
            if (typeof value === 'string') {
                arr.push(new Promise(function (res, rej) {
                    let nextHref = new URL(value, baseHref).href
                    Vue2Loader.loadObject(nextHref)
                        .then(function (obj) {
                            vueOptions.mixins[i] = obj
                            res(true)
                        }).catch(function (err) {
                        console.warn('load mixin failure!', nextHref)
                        rej(false)
                    })
                }))
            }
        }
    }
    if (vueOptions.directives) {
        Object.keys(vueOptions.directives).forEach(function (key) {
            let value = vueOptions.directives[key]
            if (typeof value === 'string') {
                arr.push(new Promise(function (res, rej) {
                    let nextHref = new URL(value, baseHref).href
                    Vue2Loader.loadObject(nextHref)
                        .then(function (obj) {
                            vueOptions.directives[key] = obj
                            Vue.directive(key, obj)
                            res(true)
                        }).catch(function (err) {
                        console.warn('load directive failure!', nextHref)
                        rej(false)
                    })
                }))
            } else {
                Vue.directive(key, value)
            }
        })
    }
    if (vueOptions.objects) {
        Object.keys(vueOptions.objects).forEach(function (key) {
            let value = vueOptions.objects[key]
            if (typeof value === 'string') {
                arr.push(new Promise(function (res, rej) {
                    let nextHref = new URL(value, baseHref).href
                    Vue2Loader.loadObject(nextHref)
                        .then(function (obj) {
                            vueOptions.objects[key] = obj
                            Vue.prototype[key] = obj
                            res(true)
                        }).catch(function (err) {
                        console.warn('load object failure!', nextHref)
                        rej(false)
                    })
                }))
            } else {
                Vue.prototype[key] = value
            }
        })
    }

    return new Promise(function (resolve, reject) {
        Promise.all(arr)
            .then(function (all) {
                resolve(vueOptions)
            }).catch(function (err) {
            console.warn('some options not resolve!')
            resolve(vueOptions)
        })
    })
}

/**
 * suffix -> mime-type/content-type mapping
 *
 * @type {Map<string,string>}
 * @private
 */
Vue2Loader._SUFFIX_MIME_TYPE_MAP=
    {
        //{后缀名，    MIME类型}
        ".txt": "text/plain",
        ".text": "text/plain",
        ".htm": "text/html",
        ".html": "text/html",
        ".stm": "text/html",
        ".xhtml": "application/xhtml+xml",
        ".js": "text/javascript",
        ".css": "text/css",
        ".xml": "text/xml",
        ".json": "application/json",
        ".pdf": "application/pdf",
        ".doc": "application/msword",
        ".xls": "application/vnd.ms-excel",
        ".ppt": "application/vnd.ms-powerpoint",
        ".wps": "application/vnd.ms-works",
        ".vsd": "application/vnd.visio",
        ".pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        ".xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ".vue": "text/plain",
        ".c": "text/plain",
        ".cpp": "text/plain",
        ".h": "text/plain",
        ".hpp": "text/plain",
        ".phps": "text/text",
        ".java": "text/x-java",
        ".py": "text/plain",
        ".go": "text/plain",
        ".sh": "text/plain",
        ".bat": "text/plain",
        ".csv": "text/csv",
        ".dot": "application/msword",
        ".pot": "application/vnd.ms-powerpoint",
        ".pps": "application/vnd.ms-powerpoint",
        ".xlt": "application/vnd.ms-excel",
        ".xlw": "application/vnd.ms-excel",
        ".ppsx": "application/vnd.openxmlformats-officedocument.presentationml.slideshow",
        ".potx": "application/vnd.openxmlformats-officedocument.presentationml.template",
        ".xltx": "application/vnd.openxmlformats-officedocument.spreadsheetml.template",
        ".conf": "text/plain",
        ".log": "text/plain",
        ".asm": "text/plain",
        ".prop": "text/plain",
        ".rc": "text/plain",
        ".ini": "text/plain",
        ".dotx": "application/vnd.openxmlformats-officedocument.wordprocessingml.template",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".png": "image/png",
        ".gif": "image/gif",
        ".ico": "image/ico",
        ".wbmp": "image/vnd.wap.wbmp",
        ".webp": "image/webp",
        ".bmp": "image/bmp",
        ".tif": "image/tiff",
        ".tiff": "image/tiff",
        ".psd": "image/x-photoshop",
        ".jpe": "image/jpeg",
        ".cur": "image/ico",
        ".svg": "image/svg+xml",
        ".svgz": "image/svg+xml",
        ".ttf": "font/ttf",
        ".woff": "font/woff",
        ".otf": "font/otf",
        ".woff2": "font/woff2",
        ".aac": "audio/aac",
        ".mp3": "audio/mpeg",
        ".wav": "audio/wav",
        ".oga": "audio/ogg",
        ".m4a": "audio/mpeg",
        ".mp2": "audio/mpeg",
        ".mpega": "audio/mpeg",
        ".mpga": "audio/mpeg",
        ".m3u": "audio/mpegurl",
        ".flac": "application/x-flac",
        ".amr": "audio/amr",
        ".ogg": "application/ogg",
        ".ogx": "application/ogg",
        ".mp4": "video/mp4",
        ".avi": "video/x-msvideo",
        ".mpeg": "video/mpeg",
        ".mov": "video/quicktime",
        ".rmvb": "video/vdn.rn-realvideo",
        ".flv": "video/x-flv",
        ".mkv": "video/x-matroska",
        ".mpg4": "video/mp4",
        ".m4b": "audio/mp4a-latm",
        ".m4p": "audio/mp4a-latm",
        ".m4u": "video/vnd.mpegurl",
        ".qt": "video/quicktime",
        ".vob": "video/mpeg",
        ".ogv": "video/ogg",
        ".wmv": "video/x-ms-wmv",
        ".movie": "video/x-sgi-movie",
        ".fli": "video/fli",
        ".m4v": "video/m4v",
        ".3g2": "video/3gpp",
        ".3gp": "video/3gpp",
        ".3gpp": "video/3gpp",
        ".mpa": "video/mpeg",
        ".mpe": "video/mpeg",
        ".mpg": "video/mpeg",
        ".mpv2": "video/mpeg",
        ".asf": "video/x-ms-asf",
        ".mv": "video/x-sgi-movie",
        ".m13": "application/x-msmediaview",
        ".m14": "application/x-msmediaview",
        ".mvb": "application/x-msmediaview",
        ".wmf": "application/x-msmetafile",
        ".7z": "application/x-7z-compressed",
        ".bz": "application/x-bzip",
        ".bz2": "application/x-bzip2",
        ".z": "application/x-compress",
        ".gtar": "application/x-gtar",
        ".taz": "application/x-gtar",
        ".tgz": "application/x-gtar",
        ".gz": "application/x-gzip",
        ".tar": "application/x-tar",
        ".zip": "application/zip",
        ".jar": "application/java-archive",
        ".rar": "application/rar",
        ".apk": "application/vnd.android.package-archive",
        ".exe": "application/octet-stream",
        ".class": "application/octet-stream",
        ".cod": "image/cis-cod",
        ".ief": "image/ief",
        ".pcx": "image/pcx",
        ".jfif": "image/pipeg",
        ".djv": "image/vnd.djvu",
        ".djvu": "image/vnd.djvu",
        ".ras": "image/x-cmu-raster",
        ".cmx": "image/x-cmx",
        ".cdr": "image/x-coreldraw",
        ".pat": "image/x-coreldrawpattern",
        ".cdt": "image/x-coreldrawtemplate",
        ".art": "image/x-jg",
        ".jng": "image/x-jng",
        ".pnm": "image/x-portable-anymap",
        ".pbm": "image/x-portable-bitmap",
        ".pgm": "image/x-portable-graymap",
        ".ppm": "image/x-portable-pixmap",
        ".rgb": "image/x-rgb",
        ".xbm": "image/x-xbitmap",
        ".xpm": "image/x-xpixmap",
        ".xwd": "image/x-xwindowdump",
        ".au": "audio/basic",
        ".snd": "audio/basic",
        ".mid": "audio/mid",
        ".rmi": "audio/mid",
        ".kar": "audio/midi",
        ".midi": "audio/midi",
        ".xmf": "audio/midi",
        ".mxmf": "audio/mobile-xmf",
        ".sid": "audio/prs.sid",
        ".weba": "audio/webm",
        ".aif": "audio/x-aiff",
        ".aifc": "audio/x-aiff",
        ".aiff": "audio/x-aiff",
        ".gsm": "audio/x-gsm",
        ".wax": "audio/x-ms-wax",
        ".wma": "audio/x-ms-wma",
        ".ram": "audio/x-pn-realaudio",
        ".rm": "audio/x-pn-realaudio",
        ".qcp": "audio/x-qcp",
        ".ra": "audio/x-realaudio",
        ".pls": "audio/x-scpls",
        ".sd2": "audio/x-sd2",
        ".dl": "video/dl",
        ".dif": "video/dv",
        ".dv": "video/dv",
        ".mxu": "video/vnd.mpegurl",
        ".webm": "video/webm",
        ".lsf": "video/x-la-asf",
        ".lsx": "video/x-la-asf",
        ".mng": "video/x-mng",
        ".asr": "video/x-ms-asf",
        ".asx": "video/x-ms-asf",
        ".wm": "video/x-ms-wm",
        ".wmx": "video/x-ms-wmx",
        ".wvx": "video/x-ms-wvx",
        ".mjs": "text/javascript",
        ".cls": "text/x-tex",
        ".diff": "text/plain",
        ".xla": "application/vnd.ms-excel",
        ".xlc": "application/vnd.ms-excel",
        ".xlm": "application/vnd.ms-excel",
        ".eot": "application/vnd.ms-fontobject",
        //unknown type to binary common mime
        "": "application/octet-stream"
    }