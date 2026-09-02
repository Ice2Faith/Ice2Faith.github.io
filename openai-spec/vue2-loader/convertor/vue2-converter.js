function FileSystemItem(){
    /**
     * @type {string|null}
     */
    this.name= null;
    /**
     * @type {FileSystemHandle|null}
     */
    this.handle= null;
    /**
     * @type {string|null}
     */
    this.path= null;
    /**
     * @type {string|null}
     */
    this.parentPath= null;
    /**
     * @type {FileSystemDirectoryHandle|null}
     */
    this.parent= null;
    /**
     * @type {File|null}
     */
    this.file= null;
    /**
     * @type {boolean}
     */
    this.isFile= false;
}


/**
 * @constructor
 * @return {Vue2Converter}
 * @type {Vue2Converter}
 */
function Vue2Converter() {

}
/**
 * @param logger {function(string)}
 * @return {void}
 */
Vue2Converter.convertProjectFiles = async function (logger) {
    let files=await Vue2Converter.getProjectFiles()
    await Vue2Converter.convertFiles(files,logger)
}

/**
 * 
 * @return {FileSystemItem[]}
 */
Vue2Converter.getProjectFiles=async function(){
    let projectDirFileHandle = await Vue2Converter.getDirectoryHandle()
    return await Vue2Converter.scanFilesMapping(projectDirFileHandle)
}

/**
 * 
 * @return {FileSystemDirectoryHandle}
 */
Vue2Converter.getDirectoryHandle=async function(){
    return await showDirectoryPicker({
        mode: 'readwrite',
        startIn: 'desktop',
        id: 'project_home'
    })
}

/**
 * 
 * @param files {FileSystemItem[]}
* @param logger {function(string)}
 * @return {void}
 */
Vue2Converter.removeGeneratedFiles=function(files,logger){
    if(!files){
        return
    }
    for (let i = 0; i < files.length; i++) {
        const item = files[i];
        if(item.name.endsWith('.jsonp.js')){
            logger('remove file:'+item.path)
            item.handle.remove()
            continue
        }
        if(item.name.endsWith('.iframe.txt')){
            logger('remove file:'+item.path)
            item.handle.remove()
            continue
        }
    }
}

/**
 * 
 * @param files {FileSystemItem[]}
* @param logger {function(string)}
 * @return {void}
 */
Vue2Converter.convertFiles=async function(files,logger){
    if(!files){
        return
    }
    for (let i = 0; i < files.length; i++) {
        const item = files[i];
        await Vue2Converter.convertFile(item,logger)
    }
}

/**
 * 
 * @param item {FileSystemItem}
 * @param logger {function(string)}
 * @return {void}
 */
Vue2Converter.convertFile=async function(item,logger) {
    if (!item.isFile) {
        return
    }
    if (item.name.endsWith('.jsonp.js')) {
        return
    }
    if (item.name.endsWith('.iframe.txt')) {
        return
    }

    if (!item.name.endsWith('.vue') && !item.name.endsWith('.js')) {
        return
    }

    if(!logger){
        logger=console.log
    }

    let text = await Vue2Converter.readTextFile(item.file)
    if (text) {
        let newName = item.name + '.jsonp.js'
        logger('write jsonp:' + item.path + ' ==> ' + newName)
        let jsonp = 'jsonp_callback(' + JSON.stringify(text) + ')'
        let jsonpFileHandle = await item.parent.getFileHandle(newName, { create: true })
        Vue2Converter.writeTextFile(jsonpFileHandle, jsonp)
    }

    if (text) {
        let newName = item.name + '.iframe.txt'
        logger('write iframe:' + item.path + ' ==> ' + newName)
        let iframeFileHandle = await item.parent.getFileHandle(newName, { create: true })
        Vue2Converter.writeTextFile(iframeFileHandle, text)
    }
}

/**
 * 
 * @param file {File}
 * @return {string}
 */
Vue2Converter.readTextFile = async function (file) {
    return await new Promise((resolve, reject) => {
        try {
            const reader = new FileReader();
            reader.onload = function () {
                resolve(reader.result);
            }
            reader.readAsText(file);
        } catch (e) {
            reject(e)
        }
    })
}

/**
 * 
 * @param fileHandle {FileSystemHandle}
 * @param text {string}
 */
Vue2Converter.writeTextFile = async function (fileHandle, text) {
    let writer = await fileHandle.createWritable()
    await writer.write(text)
    await writer.close()
}


/**
 * 
 * @param rootDirHandle {FileSystemHandle}
 * @return {FileSystemItem[]}
 */
Vue2Converter.scanFilesMapping = async function (rootDirHandle) {
    return await Vue2Converter.scanFilesMappingNext(rootDirHandle)
}

/**
 * 
 * @param rootDirHandle {FileSystemHandle}
 * @param dirPath {string}
 * @return {FileSystemItem[]}
 */
Vue2Converter.scanFilesMappingNext = async function (rootDirHandle, dirPath) {
    let ret = []
    if (!rootDirHandle) {
        return ret
    }
    if (!dirPath) {
        dirPath = ''
    }
    for await (const [name, handle] of rootDirHandle.entries()) {

        let item = new FileSystemItem()
        item.name= name
        item.handle= handle
        item.path= dirPath + '/' + name
        item.parentPath= dirPath
        item.parent= rootDirHandle
        item.file= null
        item.isFile= false
        

        ret.push(item)

        if (handle.kind === 'file') {
            item.isFile = true
            item.file = await item.handle.getFile()
        } else {
            let next = await Vue2Converter.scanFilesMappingNext(handle, item.path)
            ret.push(...next)
        }
    }
    return ret
}
