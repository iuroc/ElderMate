import { MessageData } from "../components/MessageListItem"
import { BusinessError, pasteboard } from "@kit.BasicServicesKit"
import { promptAction } from "@kit.ArkUI"
import { systemShare } from "@kit.ShareKit"
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common } from "@kit.AbilityKit"

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

/** 调用系统文本分享时的标题 */
export async function getShareTextTitle() {
    return getContext().resourceManager.getStringValue($r('app.string.text_share_title'))
}


@ObservedV2
export class MenuElementObservedV2 implements MenuElement {
    @Trace value: ResourceStr
    @Trace icon?: ResourceStr
    @Trace symbolIcon?: SymbolGlyphModifier
    @Trace enabled?: boolean
    @Trace action: () => void

    constructor(menuElement: MenuElement) {
        this.value = menuElement.value
        this.icon = menuElement.icon
        this.symbolIcon = menuElement.symbolIcon
        this.enabled = menuElement.enabled
        this.action = menuElement.action
    }
}