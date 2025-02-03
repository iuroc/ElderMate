import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { filePreview } from '@kit.PreviewKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { request } from '@kit.BasicServicesKit'

/**
 * 根据文件后缀查询 Mime 类型
 * @param extention 文件后缀，以 . 开头
 * @returns MimeType
 */
export function extToMime(extention: string) {
    const typeId = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(extention)
    const typeObj = uniformTypeDescriptor.getTypeDescriptor(typeId)
    const mimeTypes = typeObj.mimeTypes
    return mimeTypes
}

/**
 * 根据路径或 uri 获取后缀，以 . 开头
 * @param path
 * @returns
 */
export function extname(path: string) {
    return path.substring(path.lastIndexOf('.'))
}

/**
 * 将 Date 转换为中文字符串
 * @param date 需要转换的 Date 对象
 * @param includeTime 是否包含时间，默认只含日期
 * @returns
 */
export function formatDateChinese(date: Date, includeTime: boolean = false): string {
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')

    if (includeTime) {
        const hours = date.getHours().toString().padStart(2, '0')
        const minutes = date.getMinutes().toString().padStart(2, '0')
        const seconds = date.getSeconds().toString().padStart(2, '0')
        return `${year}年${month}月${day}日 ${hours}点${minutes}分${seconds}秒`
    } else {
        return `${year}年${month}月${day}日`
    }
}

/**
 * 获取网络图片的本地预览路径
 * @param url
 * @returns
 */
export function getPreviewFileUriForImageURL(url: string) {
    return new Promise<string>((resolve, reject) => {
        const filePath = getContext().filesDir + '/' + url.replaceAll(/[\/:]/g, '')
        if (!fileIo.accessSync(filePath)) {
            request.downloadFile(getContext(), {
                url: url,
                filePath
            }).then(task => {
                task.on('complete', () => {
                    resolve(fileUri.getUriFromPath(filePath))
                })
                task.on('fail', error => {
                    reject(new Error(error.toString()))
                })
            })
        } else {
            resolve(fileUri.getUriFromPath(filePath))
        }
    })
}