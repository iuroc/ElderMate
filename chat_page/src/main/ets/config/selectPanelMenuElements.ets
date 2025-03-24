import { BSColor } from '@iuroc/bootstrap5-color'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { BottomPanel } from '../components/BottomPanel'
import { deleteMessageById } from '../utils/db'
import {
    copyTextWithToast,
    getShareTextTitle,
    selectedItems,
    sendMailWithToast,
    systemShareTextWithToast
} from '../utils/utils'

/** 选中项操作菜单 */
export function selectPanelMenuElements(that: BottomPanel): MenuElement[] {
    return [
        {
            value: $r('app.string.copy_text'),
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.rectangle_on_rectangle')),
            action: () => {
                copyTextWithToast(that.mergeSelectedContent()).finally(() => {
                    that.quitSelectMode()
                })
            }
        },
        {
            value: $r('app.string.share_text'),
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
            action: async () => {
                systemShareTextWithToast(await getShareTextTitle(), that.mergeSelectedContent()).finally(() => {
                    that.quitSelectMode()
                })
            },
        },
        {
            value: $r('app.string.send_to_email'),
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),
            action: async () => {
                sendMailWithToast(await getShareTextTitle(), that.mergeSelectedContent()).finally(() => {
                    that.quitSelectMode()
                })
            }
        },
        {
            value: $r('app.string.delete_message'),
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([BSColor.danger]),
            action: async () => {
                AlertDialog.show({
                    title: '操作提示',
                    primaryButton: {
                        value: '确定',
                        fontColor: BSColor.danger, action: () => {
                            selectedItems(that.messageDataList).forEach(needDeleteItem => {
                                that.messageDataList.splice(
                                    that.messageDataList.findIndex(item => item.id == needDeleteItem.id),
                                    1
                                )
                                deleteMessageById(that.rdbStore, needDeleteItem.id)
                            })
                            that.quitSelectMode()
                        }
                    },
                    secondaryButton: {
                        value: '取消',
                        action: () => {
                        }
                    },
                    message: '确定要删除所选的消息吗？'
                })
            },
        },
    ]
}
