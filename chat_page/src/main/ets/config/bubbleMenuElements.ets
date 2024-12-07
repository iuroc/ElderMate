import { BSColor } from '@iuroc/bootstrap5-color'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { MessageListItem } from '../components/MessageListItem'
import { deleteMessageById } from '../utils/db'
import {
    copyTextWithToast,
    getShareTextTitle,
    selectableItems,
    sendMailWithToast,
    systemShareTextWithToast
} from '../utils/utils'

/** 消息气泡的绑定菜单配置 */
export function bubbleMenuElements(that: MessageListItem): MenuElement[] {
    return [
        {
            value: '复制文本',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.rectangle_on_rectangle')),
            action: () => {
                copyTextWithToast(that.messageData.content)
            }
        },
        {
            value: '选择文本',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.selector')),
            action: () => {
                that.isTextSelectModalShow = true
                that.textSelectModalText = that.messageData.content
            }
        },
        {
            value: '分享文本',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
            action: async () => {
                systemShareTextWithToast(
                    await getShareTextTitle(),
                    that.messageData.content
                )
            },
        },
        {
            value: '多选模式',
            enabled: selectableItems(that.messageDataList).length > 1,
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_checkmask')),
            action: () => {
                that.autoScrollToBottom = false
                that.isSelectMode = true
                that.messageData.selected = true
            }
        },
        {
            value: '发送到邮箱',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),

            action: async () => {
                await sendMailWithToast(await getShareTextTitle(), that.messageData.content)
            }
        },
        {
            value: '删除消息',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([BSColor.danger]),
            action: () => {
                that.messageDataList.forEach((item, index) => {
                    if (item.id == that.messageData.id) {
                        that.messageDataList.splice(index, 1)
                        deleteMessageById(that.rdbStore, item.id)
                    }
                })
            },
        },
    ]
}
