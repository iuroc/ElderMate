import { fileIo, fileUri } from '@kit.CoreFileKit'
import { BusinessError, request } from '@kit.BasicServicesKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../Login/utils'
import { extname, extToMime } from '../../common/utils'
import { http } from '@kit.NetworkKit'
import { url } from '@kit.ArkTS'
import { ApiResponse } from '../../common/types'

export function readFile(path: string): ArrayBuffer {
    const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY)
    const data = new ArrayBuffer(fileIo.statSync(path).size)
    fileIo.readSync(file.fd, data)
    fileIo.close(file)
    return data
}

export async function uploadImage(uris: string[]): Promise<request.UploadTask> {
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
    return request.uploadFile(getContext(), {
        url: apiOrigin + '/api/share/uploadImage',
        header: { token: await getToken() },
        method: 'POST',
        files: files,
        data: []
    })
}


/**
 * 发布内容或评论
 * @param content 发布的内容
 * @param type 发布的内容类型，post 帖子 comment 评论
 * @param images 发布帖子时的配图
 * @returns 发布后产生的新纪录
 */
export async function createShare(content: string, type: 'post' | 'comment', images: string[] = []) {
    const request = http.createHttp()
    const params = new url.URLParams({
        content,
        type,
    })
    if (type == 'post' && images.length > 0) {
        params.set('images', images.join('|'))
    }
    const response = await request.request(apiOrigin + '/api/share/create', {
        method: http.RequestMethod.POST,
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: params.toString(),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<CreateShareResult>
    if (result.success) {
        return result.data
    } else {
        throw new Error(result.message)
    }
}

interface CreateShareResult {
    id: number
    createTime: string
    likeCount: number
    isDeleted: number
}