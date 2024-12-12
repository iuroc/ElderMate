import { MessageList } from './MessageList'
import { BottomPanel } from './BottomPanel'
import { BSColorGroup } from '../common/types'
import { BSColor, BSColorNameMap, getColorGroup } from '@iuroc/bootstrap5-color'
import { defaultChatModel, defaultChatTitle, defaultMessages, defaultThemeColorName } from '../common/config'
import { preferences, relationalStore } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { createChat, getAllChatSorted, getMessagesByChatID, initTables, insertMessages } from '../common/db'
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
    @Provider() currentChatIndex: number = 0

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
    }

    initRdbStore() {
        this.loadRdbStore().then(rdbStore => {
            this.rdbStore = rdbStore
            initTables(rdbStore).catch((error: BusinessError) => {
                promptAction.showToast({ message: `数据表初始化失败：${error.data}` })
            }).then(() => {
                this.chats = getAllChatSorted(this.rdbStore)
                if (this.chats.length == 0) {
                    console.log('table chat is empty, unshiftNewChatToList.')
                    this.unshiftNewChatToList()
                }
                this.showChat(0)
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

    /** 切换当前页面显示的 Chat 信息和消息列表，并更新 `currentChatId` */
    showChat(index: number) {
        this.currentChatIndex = index
        this.messages = getMessagesByChatID(this.rdbStore, this.chats[this.currentChatIndex].id)
    }

    /**
     * 创建一条新的 `chat` 记录，并插入到数组的开头，不会刷新当前页面显示内容，需要调用 `showChat` 显示内容
     *
     * 使用 `Array.unshift()` 实现插入元素到数组开头
     */
    unshiftNewChatToList() {
        const newChatData = createChat(this.rdbStore, defaultChatTitle, defaultChatModel)
        insertMessages(this.rdbStore, newChatData.id, defaultMessages())
        this.chats.unshift(newChatData)
    }
}