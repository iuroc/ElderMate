import { fileIo } from '@kit.CoreFileKit'
import { request } from '@kit.BasicServicesKit'
import { apiOrigin } from '../../common/config'
import { getToken, getUserInfo } from '../Login/utils'
import { extname, extToMime } from '../../common/utils'
import { http } from '@kit.NetworkKit'
import { url } from '@kit.ArkTS'
import { ApiResponse } from '../../common/types'
import { ShareCommentObservedV2, SharePostObservedV2, UserInPostObservedV2 } from './Page'

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

export interface CreateCommentConfig {
    postId: number
    commentId?: number
    content: string
    type: 'comment'
}

export interface CreatePostConfig {
    content: string
    images: string[]
    type: 'post'
}

/**
 * 发布内容或评论
 * @param content 发布的内容
 * @param type 发布的内容类型，post 帖子 comment 评论
 * @param images 发布帖子时的配图
 * @returns 发布后产生的新纪录
 */
export async function createShare(config: CreateCommentConfig | CreatePostConfig) {
    const request = http.createHttp()
    const params = new url.URLParams({
        content: config.content,
        type: config.type,
    })
    if (config.type == 'post') {
        if (config.images.length > 0) {
            params.set('images', config.images.join('|'))
        }
    } else if (config.type == 'comment') {
        params.set('parentPostId', config.postId.toString())
        if (config.commentId) {
            params.set('parentCommentId', config.commentId.toString())
        }
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

export interface CreateShareResult {
    id: number
    createTime: string
    likeCount: number
    isDeleted: number
}

export interface ISharePost extends IShareContent {
    comments_of_post: IShareComment[]
    images: ImageInShareContent[]
    isLike: boolean
    type: 'post'
}

export interface ImageInShareContent {
    id: number
    url: string
}

export interface IShareContent {
    id: number
    user: IUserInContent
    content: string
    createTime: string
    likeCount: number
    isDelete: number
}

export interface IShareComment extends IShareContent {
    type: 'comment'
    parent_comment: IParentComment | null
}

export interface IParentComment {
    id: number
    user: IUserInContent
}

interface IUserInContent {
    id: number
    nickName: string
}

export async function getSharePostList(page: number = 0, pageSize: number = 36) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/share/list', {
        method: http.RequestMethod.POST,
        extraData: new url.URLParams({
            page: page.toString(),
            pageSize: pageSize.toString()
        }).toString(),
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        expectDataType: http.HttpDataType.OBJECT,
    })
    const result = response.result as ApiResponse<ISharePost[]>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}

export function iSharePostToObservedV2(list: ISharePost[]) {
    return list.map(item => {
        const sharePost = new SharePostObservedV2()
        sharePost.id = item.id
        sharePost.user = new UserInPostObservedV2(item.user.id, item.user.nickName)
        sharePost.content = item.content
        sharePost.createTime = item.createTime
        // sharePost.likeCount = item.likeCount
        // sharePost.isDeleted = item.isDelete
        sharePost.images = item.images.map(i => i.url)
        sharePost.isLike = item.isLike
        sharePost.comments_of_post = item.comments_of_post.map(comment => {
            const shareComment = new ShareCommentObservedV2()
            shareComment.id = comment.id
            shareComment.user = new UserInPostObservedV2(comment.user.id, comment.user.nickName)
            shareComment.content = comment.content
            shareComment.createTime = comment.createTime
            // shareComment.likeCount = comment.likeCount
            // shareComment.isDeleted = comment.isDelete
            // shareComment.parent_comment_nickName = comment.parent_comment?.user.nickName
            if (comment.parent_comment) {
                shareComment.parent_comment_user =
                    new UserInPostObservedV2(comment.parent_comment.user.id, comment.parent_comment.user.nickName)
            }
            return shareComment
        }) as ShareCommentObservedV2[]
        return sharePost
    }) as SharePostObservedV2[]
}

/** 反转点赞状态，返回点赞后的状态 */
export async function shareLike(id: number) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/share/like', {
        method: http.RequestMethod.POST,
        extraData: `id=${id}`,
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<boolean>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}

/**
 * 删除发布的内容，包括删除帖子和评论
 * @param id 需要删除的帖子或评论的 ID
 * @throws { Error } 删除失败
 */
export async function deleteContent(id: string) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/share/delete', {
        method: http.RequestMethod.POST,
        extraData: new url.URLParams({ id }).toString(),
        expectDataType: http.HttpDataType.OBJECT,
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
    })
    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}

/**
 * 用于在对帖子或评论发布评论后，将请求结果转换为 CommentObservedV2
 * @param result
 * @param content
 * @param parentCommentNickname
 * @returns
 */
export function createShareResultToCommentObservedV2(
    result: CreateShareResult,
    content: string,
    parentCommentUser?: UserInPostObservedV2
) {
    const comment = new ShareCommentObservedV2()
    comment.content = content
    comment.id = result.id
    comment.createTime = result.createTime
    const user = getUserInfo()
    comment.user = new UserInPostObservedV2(user.id, user.nickName)
    comment.parent_comment_user = parentCommentUser
    return comment
}
