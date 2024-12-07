import { BSColor, getColorGroup } from '@iuroc/bootstrap5-color'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { MainPage } from '../components/MainPage'
import {
    createNewChatForPage,
    deleteMessagesByChatId,
    getMessagesByChatID,
    insertMessages,
    sortChatList
} from '../utils/db'
import { selectableItems } from '../utils/utils'
import { defaultMessageDataList } from './defaultMessageDataList'

export function navigationMenuItems(that: MainPage): NavigationMenuItem[] {
    return that.isSelectMode ? [] : [
        {
            value: '创建新对话',
            isEnabled: selectableItems(that.messageDataList).length > 0 && !that.isChatRequesting,
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
            action: () => {
                createNewChatForPage(that.rdbStore, that.chatDataList, that.defaultOpenaiModel)
                const newChatData = sortChatList(that.chatDataList)[0]
                that.currentChatId = newChatData.id
                that.messageDataList = getMessagesByChatID(that.rdbStore, newChatData.id)
            }
        },
        {
            value: '清空当前消息列表',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
            isEnabled: selectableItems(that.messageDataList).length > 0 && !that.isChatRequesting,
            action: () => {
                that.textAreaController.stopEditing()
                AlertDialog.show({
                    title: '操作提示',
                    message: '确定要清空当前消息列表吗？',
                    primaryButton: {
                        value: '确定',
                        fontColor: BSColor.danger,
                        action: () => {
                            that.messageDataList = defaultMessageDataList()
                            deleteMessagesByChatId(that.rdbStore, that.currentChatId)
                            insertMessages(that.rdbStore, that.currentChatId, that.messageDataList)
                        }
                    },
                    secondaryButton: {
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
            value: '设置',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
            action: () => {
                that.textAreaController.stopEditing()
                that.settingDialogController.open()
            }
        },
    ]
}