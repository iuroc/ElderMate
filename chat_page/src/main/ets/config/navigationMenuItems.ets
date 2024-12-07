import { BSColor, getColorGroup } from '@iuroc/bootstrap5-color'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { MainPage } from '../components/MainPage'
import { deleteMessagesByChatId, insertMessages } from '../utils/db'
import { selectableItems } from '../utils/utils'
import { defaultMessageDataList } from './defaultMessageDataList'

export function navigationMenuItems(that: MainPage): NavigationMenuItem[] {
    return that.isSelectMode ? [] : [
        {
            value: '清空当前消息列表',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
            isEnabled: selectableItems(that.messageDataList).length > 0,
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
                            deleteMessagesByChatId(that.rdbStore, that.chatDataList[0].id)
                            insertMessages(that.rdbStore, that.chatDataList[0].id, that.messageDataList)
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
            value: '设置',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
            action: () => {
                that.textAreaController.stopEditing()
                that.settingDialogController.open()
            }
        }
    ]
}