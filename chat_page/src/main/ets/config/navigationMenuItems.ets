import { BSColor } from '@iuroc/bootstrap5-color'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { MainPage } from '../components/MainPage'
import { deleteMessagesByChatId, insertMessages } from '../utils/db'
import { getResourceStringValue, selectableItems } from '../utils/utils'

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
            action: async () => {
                AlertDialog.show({
                    title: await getResourceStringValue($r('app.string.operation_tip')),
                    message: await getResourceStringValue($r('app.string.confirm_clear_message_list')),
                    secondaryButton: {
                        value: await getResourceStringValue($r('app.string.confirm_button')),
                        fontColor: BSColor.danger,
                        action: () => {
                            deleteMessagesByChatId(that.rdbStore, that.currentChat().id)
                            that.messageDataList = that.defaultMessageDataList
                            insertMessages(that.rdbStore, that.currentChat().id, that.messageDataList)
                        }
                    },
                    primaryButton: {
                        value: await getResourceStringValue($r('app.string.cancel_button')),
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

export async function ____navigationMenuItems(that: MainPage): Promise<NavigationMenuItem[]> {
    return that.isSelectMode ? [] : [
        {
            value: await getResourceStringValue($r('app.string.create_new_conversation')),
            isEnabled: selectableItems(that.messageDataList).length > 0 && !that.isChatRequesting,
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
            action: () => {
                that.unshiftNewChatToList()
                that.showChat(0)
            }
        },
        {
            value: await getResourceStringValue($r('app.string.clear_current_message_list')),
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
            isEnabled: selectableItems(that.messageDataList).length > 0 && !that.isChatRequesting,
            action: async () => {
                AlertDialog.show({
                    title: await getResourceStringValue($r('app.string.operation_tip')),
                    message: await getResourceStringValue($r('app.string.confirm_clear_message_list')),
                    secondaryButton: {
                        value: await getResourceStringValue($r('app.string.confirm_button')),
                        fontColor: BSColor.danger,
                        action: () => {
                            deleteMessagesByChatId(that.rdbStore, that.currentChat().id)
                            that.messageDataList = that.defaultMessageDataList
                            insertMessages(that.rdbStore, that.currentChat().id, that.messageDataList)
                        }
                    },
                    primaryButton: {
                        value: await getResourceStringValue($r('app.string.cancel_button')),
                        action: () => {
                        }
                    }
                })
            }
        },
        {
            value: await getResourceStringValue($r('app.string.conversation_history')),
            isEnabled: that.chatDataList.length > 1 && !that.isChatRequesting,
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise_clock')),
            action: () => {
                that.chatListDialogController.open()
            }
        },
        {
            value: await getResourceStringValue($r('app.string.modify_title')),
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.rename')),
            action: () => {
                that.renameDialogChatDataIndex = that.currentChatIndex
                that.chatRenameDialogController.open()
            }
        },
        {
            value: await getResourceStringValue($r('app.string.more_settings')),
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
            action: () => {
                that.settingDialogController.open()
            }
        },
    ]
}