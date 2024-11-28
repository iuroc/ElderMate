import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

/** 消息列表项数据 */
export interface MessageData {
    /** 消息角色，如果是 `info
     ` 则不会参与文本生成 */
    role: 'user' | 'assistant' | 'system' | 'info'
    content: string
    /** 默认请设置为 `new Date()` */
    createTime: Date
    hidden?: boolean
    /** 请使用 `util.generateRandomUUID(false)` 生成 */
    uuid: string
    selected?: boolean
}

/** Scroller 滚动到底部 */
export function scrollToBottom(scroller: Scroller, animation = true) {
    scroller.scrollTo({
        xOffset: 0,
        yOffset: scroller.getItemRect(0).height,
        animation
    })
}

/** 获取可见且可选的消息记录 */
export function getSelectableItems(messageDataList: MessageData[]): MessageData[] {
    return messageDataList.filter(item => item.role != 'info' && !item.hidden)
}

/** 获取选中的可见消息记录 */
export function getSelectedItems(messageDataList: MessageData[]): MessageData[] {
    return messageDataList.filter(item => item.selected && item.role != 'info' && !item.hidden)
}

/** 判断当前消息列表是否被全选 */
export function isAllSelected(messageDataList: MessageData[]): boolean {
    return messageDataList.filter(item =>!item.selected && item.role != 'info' && !item.hidden).length == 0
}

/**
 * 调用系统能力分享文本
 * @param context
 * @param record 需要分享的数据
 * @throws { BusinessError } 401 - Parameter error.
 */
export async function systemShareText(
    context: Context,
    title: string,
    content: string
): Promise<void> {
    const sharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.TEXT,
        title, content,
    })
    const controller = new systemShare.ShareController(sharedData)
    await controller.show(context as common.UIAbilityContext, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DETAIL,
    })
}

/**
 * 合并多条消息为用于分享的纯文本，包含 `user` 和 `assistant` 消息
 * @param items
 * @returns
 */
export function mergedMessageForSharing(items: MessageData[]) {
    return items.map(item => {
        return `【${item.role}】\n${item.content.trim()}`
    }).join(`\n${'-'.repeat(20)}\n`)
}

interface HasMessageDataList {
    messageDataList: MessageData[]
}

/** 删除指定 `UUID` 的消息 */
export function deleteByUUID(that: HasMessageDataList, uuid: string): void {
    for (let i = 0; i < that.messageDataList.length; i++) {
        if (that.messageDataList[i].uuid == uuid) {
            that.messageDataList.splice(i, 1)
            return
        }
    }
}

/** 设置全选或全不选，将例外项将设置为相反的值 */
export function changeAllSelectStatus(that: HasMessageDataList, selected: boolean, ...excepts: string[]) {
    that.messageDataList = that.messageDataList.map(item => {
        item.selected = excepts.includes(item.uuid) ? !selected : selected
        return item
    })
}