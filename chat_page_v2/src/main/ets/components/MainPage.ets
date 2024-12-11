import { MessageList } from './MessageList'
import { BottomPanel } from './BottomPanel'
import { BSColorGroup } from '../common/types'
import { getColorGroup } from '@iuroc/bootstrap5-color'
import { defaultThemeColor } from '../common/config'

@ComponentV2
export struct MainPage {
    @Provider() themeColor: BSColorGroup = getColorGroup(defaultThemeColor)
    @Provider() messageInputValue: string = ''

    build() {
        NavDestination() {
            MessageList().layoutWeight(1)
            BottomPanel()
        }
        .title('聊天助手')
    }
}