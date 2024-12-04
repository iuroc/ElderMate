import { BSColor } from '@iuroc/bootstrap5-color'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { BottomPanel } from '../components/BottomPanel'
import {
    copyTextWithToast,
    getShareTextTitle,
    selectedItems,
    sendMailWithToast,
    systemShareTextWithToast
} from '../utils/utils'

/** 选择性操作菜单 */
export function selectPanelMenuElements(that: BottomPanel): MenuElement[] {
    return [
        {
            value: '复制文本',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.rectangle_on_rectangle')),
            action: () => {
                copyTextWithToast(that.mergeSelectedContent()).finally(() => {
                    that.quitSelectMode()
                })
            }
        },
        {
            value: '分享文本',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
            action: async () => {
                systemShareTextWithToast(await getShareTextTitle(), that.mergeSelectedContent()).finally(() => {
                    that.quitSelectMode()
                })
            },
        },
        {
            value: '发送到邮箱',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),
            action: async () => {
                sendMailWithToast(await getShareTextTitle(), that.mergeSelectedContent()).finally(() => {
                    that.quitSelectMode()
                })
            }
        },
        {
            value: '删除消息',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([BSColor.danger]),
            action: () => {
                AlertDialog.show({
                    title: '操作提示',
                    primaryButton: {
                        value: '确定', fontColor: BSColor.danger, action: () => {
                            selectedItems(that.messageDataList).forEach(needDeleteItem => {
                                that.messageDataList.splice(
                                    that.messageDataList.findIndex(item => item.id == needDeleteItem.id),
                                    1
                                )
                            })
                            that.quitSelectMode()
                        }
                    },
                    secondaryButton: {
                        value: '取消', action: () => {
                        }
                    },
                    message: '确定要删除所选的消息吗？'
                })
            },
        },
    ]
}
