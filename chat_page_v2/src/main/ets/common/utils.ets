import { Message } from "./Message";
import { common, wantConstant } from "@kit.AbilityKit";
import { promptAction } from "@kit.ArkUI";
import { BusinessError, pasteboard } from "@kit.BasicServicesKit";
import { systemShare } from "@kit.ShareKit";
import { uniformTypeDescriptor as utd } from '@kit.ArkData'

export function getDatetimeString(date: Date): string {
    const year = date.getFullYear(); // 获取四位数的年份
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

export const selectableThemeColorNames = ['primary', 'secondary', 'success', 'danger', 'warning', 'info', 'dark']

export function exampleMessages(): Message[] {
    return [
        new Message({
            role: 'user',
            content: '今天的天气怎么样？',
        }),
        new Message({
            role: 'assistant',
            content: '今天阳光明媚，气温在25度左右，非常适合外出活动。',
        }),
        new Message({
            role: 'user',
            content: '你有没有推荐的好书或者电影，可以分享一下你的感受吗？',
        }),
        new Message({
            role: 'assistant',
            content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。',
        }),
        new Message({
            role: 'user',
            content: '你平时喜欢做哪些运动来保持健康？',
        }),
        new Message({
            role: 'assistant',
            content: '我平时最喜欢的运动是跑步和游泳。每周我都会尽量去跑步三次，大约30分钟到一个小时，感觉非常放松。而游泳则是我喜欢的夏季运动，它不仅锻炼全身肌肉，还能让我在水中感受到凉爽，尤其是在炎热的天气里。',
        }),
        new Message({
            role: 'user',
            content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。',
        }),
        new Message({
            role: 'assistant',
            content: '今天阳光明媚，气温在25度左右，非常适合外出活动。',
        }),
        new Message({
            role: 'user',
            content: '你有没有推荐的好书或者电影，可以分享一下你的感受吗？',
        }),
        new Message({
            role: 'assistant',
            content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。',
        }),
        new Message({
            role: 'user',
            content: '你平时喜欢做哪些运动来保持健康？',
        }),
        new Message({
            role: 'assistant',
            content: '我平时最喜欢的运动是跑步和游泳。每周我都会尽量去跑步三次，大约30分钟到一个小时，感觉非常放松。而游泳则是我喜欢的夏季运动，它不仅锻炼全身肌肉，还能让我在水中感受到凉爽，尤其是在炎热的天气里。',
        })
    ]
}

/** 将文本复制到剪切板，并显示 Toast 提示 */
export async function copyTextWithToast(text: string) {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    await pasteboard.getSystemPasteboard().setData(data).then(() => {
        promptAction.showToast({ message: '复制成功' })
    }).catch((error: BusinessError) => {
        promptAction.showToast({ message: `复制失败：${error.message}` })
    })
}

/**
 * 调用系统能力分享文本，并显示 Toast 提示
 * @param record 需要分享的数据
 * @throws { BusinessError } 401 - Parameter error.
 */
export async function systemShareTextWithToast(
    title: string,
    content: string
): Promise<void> {
    try {
        const sharedData = new systemShare.SharedData({
            utd: utd.UniformDataType.TEXT,
            title, content,
        })
        const controller = new systemShare.ShareController(sharedData)
        await controller.show(getContext() as common.UIAbilityContext, {
            selectionMode: systemShare.SelectionMode.SINGLE,
            previewMode: systemShare.SharePreviewMode.DETAIL,
        })
    } catch (error) {
        promptAction.showToast({ message: `分享失败：${(error as BusinessError).message}` })
    }
}

export async function sendMailWithToast(title: string, content: string) {
    const context = getContext() as common.UIAbilityContext
    const wantParam: Record<string, Object> = {
        'sceneType': 1,
        'email': [],
        'cc': [],
        'bcc': [],
        'subject': encodeURI(title),
        'body': encodeURI(content),
        'ability.params.stream': [],
        'ability.want.params.uriPermissionFlag': wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION
    }
    const abilityStartCallback: common.AbilityStartCallback = {
        onError: (_code: number, _name: string, message: string) => {
            promptAction.showToast({ message: '失败：' + message })
        },
        onResult: (_result) => {
            promptAction.showToast({ message: '成功' })
        }
    }
    await context.startAbilityByType('mail', wantParam, abilityStartCallback).then(() => {
        promptAction.showToast({ message: '成功' })
    }).catch((error: BusinessError) => {
        promptAction.showToast({ message: '失败：' + error.message })
    })
}

/** 调用系统文本分享时的标题 */
export async function getShareTextTitle() {
    return getContext().resourceManager.getStringValue($r('app.string.text_share_title'))
}

/** 是否全部选中状态 */
export function isAllSelected(messages: Message[]): boolean {
    return messages.filter(item =>!item.selected && !item.hidden && item.role).length == 0
}

/** 显示复选框的项目数量 */
export function selectableItems(messages: Message[]): Message[] {
    return messages.filter(item =>!item.hidden && item.role)
}

/** 选中的项目数量 */
export function selectedItems(messages: Message[]): Message[] {
    return messages.filter(item =>!item.hidden && item.role && item.selected)
}