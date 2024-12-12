import { MessageList } from './MessageList'
import { BottomPanel } from './BottomPanel'
import { BSColorGroup } from '../common/types'
import { BSColorNameMap, getColorGroup } from '@iuroc/bootstrap5-color'
import { defaultMessages, defaultThemeColorName } from '../common/config'
import { preferences, relationalStore } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { initTables } from '../common/db'
import { BusinessError } from '@kit.BasicServicesKit'
import { Message } from '../common/Message'
import { Chat } from '../common/Chat'
import { exampleMessages } from '../common/utils'

@ComponentV2
export struct MainPage {
    /** 用户首选项，用于存储用户配置 */
    @Param @Once @Require dataPreferences: preferences.Preferences
    /** 关系型数据库的异步加载方法 */
    @Param @Once @Require loadRdbStore: () => Promise<relationalStore.RdbStore>
    /** 关系型数据库 */
    @Local rdbStore: relationalStore.RdbStore = Object()
    @Local messages: Message[] = []
    @Local chats: Chat[] = []
    @Provider() isSelectMode: boolean = false
    @Provider() autoScrollBottom: boolean = true
    /** 主题色资源 */
    @Provider() themeColor: BSColorGroup = Object()
    messageListScroller = new Scroller()

    build() {
        NavDestination() {
            MessageList({
                messages: this.messages,
                scroller: this.messageListScroller
            }).layoutWeight(1)
            BottomPanel({
                messages: this.messages,
                messageListScroller: this.messageListScroller
            })
        }
        .title('聊天助手')
    }

    aboutToAppear(): void {
        this.initWithPreferences()
        this.initRdbStore()
        this.initMessages()
    }

    initMessages() {
        this.messages = defaultMessages().concat(exampleMessages())
    }

    initRdbStore() {
        this.loadRdbStore().then(rdbStore => {
            this.rdbStore = rdbStore
            initTables(rdbStore).catch((error: BusinessError) => {
                promptAction.showToast({ message: `数据表初始化失败：${error.data}` })
            })
        }).catch((error: BusinessError) => {
            promptAction.showToast({ message: `载入数据库失败：${error.data}` })
        })
    }

    initWithPreferences() {
        this.initThemeColor()
    }

    initThemeColor() {
        try {
            const themeColorName = this.dataPreferences.getSync('themeColorName', defaultThemeColorName) as string
            this.themeColor = getColorGroup(themeColorName as BSColorNameMap)
        } catch (error) {
            promptAction.showToast({ message: `加载主题色失败：${error.message}` })
        }
    }
}