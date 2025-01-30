import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData'

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