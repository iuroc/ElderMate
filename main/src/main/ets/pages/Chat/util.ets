import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'
import { IMessageData, MessageDataInit, MessageRole } from './types'

@Observed
export class MessageData implements IMessageData {
    role: MessageRole
    content: string
    createTime: Date
    hidden: boolean
    selected: boolean
    uuid: string

    constructor(init: MessageDataInit) {
        this.role = init.role
        this.content = init.content.trim()
        this.createTime = init.createTime ?? new Date()
        this.hidden = init.hidden ?? false
        this.selected = init.selected ?? false
        this.uuid = init.uuid ?? util.generateRandomUUID(false)
    }
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
export function isAllSelected(list: MessageData[]): boolean {
    return list.filter(item =>!item.selected && item.role != 'info' && !item.hidden).length == 0
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

/** 删除指定 `UUID` 的消息 */
export function deleteByUUID(list: MessageData[], uuid: string): void {
    for (let i = 0; i < list.length; i++) {
        if (list[i].uuid == uuid) {
            list.splice(i, 1)
            return
        }
    }
}

/** 设置全选或全不选，将例外项将设置为相反的值，返回新的数组 */
export function changeAllSelectStatus(list: MessageData[], selected: boolean, ...excepts: string[]) {
    return list.map(item => {
        item.selected = excepts.includes(item.uuid) ? !selected : selected
        return item
    })
}

/**
 * 演示消息列表数据
 */
export function makeTempAdds(): MessageData[] {
    const dataList: MessageDataInit[] = [
        {
            role: 'user',
            content: '今天的天气怎么样？'
        },
        {
            role: 'assistant',
            content: '今天阳光明媚，气温在25度左右，非常适合外出活动。'
        },
        {
            role: 'user',
            content: '你有没有推荐的好书或者电影，可以分享一下你的感受吗？'
        },
        {
            role: 'assistant',
            content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。'
        },
        {
            role: 'user',
            content: '你平时喜欢做哪些运动来保持健康？'
        },
        {
            role: 'assistant',
            content: '我平时最喜欢的运动是跑步和游泳。每周我都会尽量去跑步三次，大约30分钟到一个小时，感觉非常放松。而游泳则是我喜欢的夏季运动，它不仅锻炼全身肌肉，还能让我在水中感受到凉爽，尤其是在炎热的天气里。'
        }
    ]
    return dataList.map(item => new MessageData(item))
}

export async function getTextShareTitle() {
    return getContext().resourceManager.getStringValue($r('app.string.ChatPage_TextSelectModal_text_share_title'))
}