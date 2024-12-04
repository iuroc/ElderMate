import { MessageData } from "../components/MessageListItem"

export class BooleanValue {
    value: boolean

    constructor(value = false) {
        this.value = value
    }
}

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