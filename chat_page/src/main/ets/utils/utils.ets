import { MessageData } from '../components/MessageListItem'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common, wantConstant } from '@kit.AbilityKit'

/** 是否全部选中状态 */
export function isAllSelected(messageDataList: MessageData[]): boolean {
    return messageDataList.filter(item =>!item.selected && !item.hidden && item.role).length == 0
}

/** 显示复选框的项目数量 */
export function selectableItems(messageDataList: MessageData[]): MessageData[] {
    return messageDataList.filter(item =>!item.hidden && item.role)
}

/** 选中的项目数量 */
export function selectedItems(messageDataList: MessageData[]): MessageData[] {
    return messageDataList.filter(item =>!item.hidden && item.role && item.selected)
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
    // return getContext().resourceManager.getStringValue($r('app.string.text_share_title'))
    return '来自聊天助手的文本分享'
}

export function getDatetimeString(date: Date): string {
    const year = date.getFullYear(); // 获取四位数的年份
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

/**
 * @deprecated
 * @param resource
 * @returns
 */
export async function getResourceStringValue(resource: Resource) {
    return getContext().resourceManager.getStringValue(resource)
}