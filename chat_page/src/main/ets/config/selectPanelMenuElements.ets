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
                    title: await getContext().resourceManager.getStringValue($r('app.string.operation_tip')),
                    primaryButton: {
                        value: await getContext().resourceManager.getStringValue($r('app.string.confirm_button')),
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
                        value: await getContext().resourceManager.getStringValue($r('app.string.cancel_button')),
                        action: () => {
                        }
                    },
                    message: await getContext().resourceManager.getStringValue($r('app.string.confirm_delete_message'))
                })
            },
        },
    ]
}
