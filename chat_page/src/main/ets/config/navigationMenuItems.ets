import { BSColor } from '@iuroc/bootstrap5-color'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { MainPage } from '../components/MainPage'
import { deleteMessagesByChatId, insertMessages } from '../utils/db'
import { selectableItems } from '../utils/utils'

export function navigationMenuItems(that: MainPage): NavigationMenuItem[] {
    return that.isSelectMode ? [] : [
        {
            value: '创建新对话',
            isEnabled: selectableItems(that.messageDataList).length > 0 && !that.isChatRequesting,
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
            action: () => {
                that.unshiftNewChatToList()
                that.showChat(0)
            }
        },
        {
            value: '清空当前消息列表',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
            isEnabled: selectableItems(that.messageDataList).length > 0 && !that.isChatRequesting,
            action: () => {
                AlertDialog.show({
                    title: '操作提示',
                    message: '确定要清空当前消息列表吗？',
                    secondaryButton: {
                        value: '确定',
                        fontColor: BSColor.danger,
                        action: () => {
                            deleteMessagesByChatId(that.rdbStore, that.currentChat().id)
                            that.messageDataList = that.defaultMessageDataList
                            insertMessages(that.rdbStore, that.currentChat().id, that.messageDataList)
                        }
                    },
                    primaryButton: {
                        value: '取消',
                        action: () => {
                        }
                    }
                })
            }
        },
        {
            value: '历史对话',
            isEnabled: that.chatDataList.length > 1 && !that.isChatRequesting,
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise_clock')),
            action: () => {
                that.chatListDialogController.open()
            }
        },
        {
            value: '修改标题',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.rename')),
            action: () => {
                that.renameDialogChatDataIndex = that.currentChatIndex
                that.chatRenameDialogController.open()
            }
        },
        {
            value: '更多设置',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
            action: () => {
                that.settingDialogController.open()
            }
        },
    ]
}