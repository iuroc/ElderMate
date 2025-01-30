import { fileIo, fileUri } from '@kit.CoreFileKit'
import { BusinessError, request } from '@kit.BasicServicesKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../Login/util'
import { extname, extToMime } from '../../common/utils'

export function readFile(path: string): ArrayBuffer {
    const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY)
    const data = new ArrayBuffer(fileIo.statSync(path).size)
    fileIo.readSync(file.fd, data)
    fileIo.close(file)
    return data
}

export async function uploadImage(uris: string[]) {
    const cacheDir = getContext().cacheDir
    const files: request.File[] = []
    uris.forEach((uri, index) => {
        /** 待复制的文件 */
        const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
        /** 复制到的文件名 */
        const destName = index + extname(uri)
        /** 复制到的文件路径 */
        const destPath = cacheDir + '/' + destName
        /** 复制到的文件 */
        const destFile = fileIo.openSync(destPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE)
        // 复制文件到缓存目录
        fileIo.copyFileSync(file.fd, destFile.fd)
        fileIo.closeSync(file)
        fileIo.closeSync(destFile)
        // 增加上传文件配置项
        files.push({
            filename: index + extname(uri),
            uri: 'internal://cache/' + destName,
            type: extToMime(extname(uri))[0],
            name: 'file'
        })
    })
    request.uploadFile(getContext(), {
        url: apiOrigin + '/api/share/uploadImage',
        header: { token: await getToken() },
        method: 'POST',
        files: files,
        data: []
    }).then(task => {
        task.on('complete', states => console.log('complete'))
        task.on('fail', states => console.error('fail'))
    }).catch((error: BusinessError) => {
        console.error(error.message)
    })
}