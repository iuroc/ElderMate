import { MessageData } from "../components/MessageListItem"
import { BusinessError, pasteboard } from "@kit.BasicServicesKit"
import { promptAction } from "@kit.ArkUI"
import { systemShare } from "@kit.ShareKit"
import { preferences, uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common, wantConstant } from "@kit.AbilityKit"
import { ClientOptions } from "@iuroc/openai/src/main/ets/openai@4.73.1"

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

export function getOpenaiConfig(dataPreferences: preferences.Preferences): OpenaiConfig {
    const apiKey = dataPreferences.getSync('openai_api_key', '') as string
    const baseURL = dataPreferences.getSync('openai_base_url', '') as string
    return { apiKey, baseURL }
}

interface OpenaiConfig {
    apiKey: string
    baseURL: string
}