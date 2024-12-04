import { MessageData } from "../components/MessageListItem"
import { BusinessError, pasteboard } from "@kit.BasicServicesKit"
import { promptAction } from "@kit.ArkUI"

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

/** 将文本复制到剪切板，并显示 Toast 提示 */
export async function copyTextWithToast(text: string) {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    await pasteboard.getSystemPasteboard().setData(data).then(() => {
        promptAction.showToast({ message: '复制成功' })
    }).catch((error: BusinessError) => {
        promptAction.showToast({ message: `复制失败：${error.message}` })
    })
}