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