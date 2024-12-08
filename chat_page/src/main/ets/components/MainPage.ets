import { BSColorNameMap } from '@iuroc/bootstrap5-color'
import { BottomPanel } from './BottomPanel'
import { MessageList } from './MessageList'
import { MessageData } from './MessageListItem'
import { TextSelectModal } from './TextSelectModal'
import { navigationMenuItems } from '../config/navigationMenuItems'
import { SettingDialog } from './SettingDialog'
import { preferences, relationalStore } from '@kit.ArkData'
import {
    initTables,
    ChatData,
    getMessagesByChatID,
    getAllChatDataSorted,
    createChat,
    insertMessages
} from '../utils/db'
import { BusinessError } from '@kit.BasicServicesKit'
import { ChatModel } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat/chat'
import { url } from '@kit.ArkTS'
import { promptAction } from '@kit.ArkUI'
import { ChatListDialog } from './ChatListDialog'
import { defaultMessageDataList } from '../config/defaultMessageDataList'

@Component
export struct MainPage {
    @Provide navTitle: string = ''
    @Provide inputMessage: string = ''
    @Provide messageDataList: MessageData[] = []
    @Provide isSelectMode: boolean = false
    /** 页面是否被触摸，从第一次触摸开始，该值由 `false` 变为 `true` */
    @Provide pageHasTouch: boolean = false
    public messageListScroller = new Scroller()
    public textAreaController = new TextAreaController()
    @Provide isTextSelectModalShow: boolean = false
    @Provide textSelectModalText: string = ''
    settingDialogController: CustomDialogController = Object()
    chatListDialogController: CustomDialogController = Object()
    /** 用户首选项 */
    @Require @Provide dataPreferences: preferences.Preferences = Object()
    /** 关系型数据库 */
    @Provide rdbStore: relationalStore.RdbStore = Object()
    @Require getRdbStore: () => Promise<relationalStore.RdbStore> = Object()
    /** 是否开启自动滚动到底部（当列表长度增加时） */
    @Provide autoScrollToBottom: boolean = true
    /** 是否显示 OpenAI 设置菜单 */
    @Provide openaiCanConfig: boolean = true
    @Provide defaultOpenaiModel: ChatModel = 'gpt-4o-mini'
    defaultOpenaiBaseURL = 'https://api.openai.com/v1'
    defaultThemeColor: BSColorNameMap = 'success'
    @Provide openaiApiKey: string = ''
    @Provide openaiBaseURL: string = ''
    @Provide openaiModel: ChatModel = this.defaultOpenaiModel
    @Provide themeColor: BSColorNameMap = this.defaultThemeColor
    /** Chat 列表，按 ID 降序排列，第一项为最新记录 */
    @Provide chatDataList: ChatData[] = []
    @Provide currentChatId: number = 0
    @Provide isChatRequesting: boolean = false

    /**
     * 调用 `getRdbStore` 同步获取数据库连接，并调用 `initTables` 初始化创建数据表
     * @throws { BusinessError }
     */
    async initRdbRestore() {
        this.rdbStore = await this.getRdbStore()
        if (this.rdbStore.version == 0) {
            this.rdbStore.version = 1
            console.log('start initTables')
            await initTables(this.rdbStore).catch((error: BusinessError) => {
                console.error('initTables', error.message)
            })
        }
    }

    /**
     * 从 resourceManager 载入字符串资源
     */
    initStringValue() {
        const resourceManager = getContext().resourceManager
        resourceManager.getStringValue($r('app.string.chat_assistant')).then(value => this.navTitle = value)
    }

    /**
     * 初始化【设置】弹窗控制器
     */
    initSettingDialogController() {
        this.settingDialogController = new CustomDialogController({
            builder: SettingDialog({}),
            onWillDismiss: () => {
                try {
                    this.saveOpenAIConfig()
                    this.settingDialogController.close()
                } catch (error) {
                    promptAction.showToast({ message: error.message })
                }
            },
        })
    }

    aboutToAppear() {
        // 从 resourceManager 载入字符串资源
        this.initStringValue()
        // 从 Preferences 中载入 OpenAI 配置
        this.initPreferences()
        // 初始化【设置】弹窗控制器
        this.initSettingDialogController()
        // 初始化【历史消息】弹窗控制器
        this.initChatListDialogController()
        this.initRdbRestore().catch((error: BusinessError) => {
            console.error(error.message)
        }).then(() => {
            this.chatDataList = getAllChatDataSorted(this.rdbStore)
            // 如果数据库中的 `chat` 表为空，则创建新的 `chat`
            if (this.chatDataList.length == 0) {
                this.unshiftNewChatToList()
            }
            this.showChat(this.chatDataList[0])
        })
    }

    /** 初始化【历史消息】弹窗控制器 */
    initChatListDialogController() {
        this.chatListDialogController = new CustomDialogController({
            builder: ChatListDialog({
                showChat: this.showChat,
                unshiftNewChatToList: this.unshiftNewChatToList
            }),
        })
    }

    /** 从 Preferences 中载入 OpenAI 配置
     *
     * - `openai_api_key` => `openaiApiKey`
     * - `openai_base_url` => `openaiBaseURL`
     * - `openai_model` => `openaiModel`
     * `themeColor`
     */
    initPreferences() {
        this.openaiApiKey = this.dataPreferences.getSync('openai_api_key', ``) as string
        this.openaiBaseURL = this.dataPreferences.getSync('openai_base_url', this.defaultOpenaiBaseURL) as string
        this.openaiModel = this.dataPreferences.getSync('openai_model', this.defaultOpenaiModel) as ChatModel
        this.themeColor = this.dataPreferences.getSync('theme_color_name', this.defaultThemeColor) as BSColorNameMap
    }

    /**
     * 保存 OpenAI 配置到 Preferences
     */
    saveOpenAIConfig() {
        if (this.openaiApiKey == '') {
            throw new Error('接口密钥不能为空')
        }
        if (!this.openaiBaseURL) {
            this.openaiBaseURL = this.defaultOpenaiBaseURL
        }
        try {
            url.URL.parseURL(this.openaiBaseURL)
        } catch (error) {
            throw new Error('接口地址格式错误')
        }
        this.dataPreferences.putSync('openai_api_key', this.openaiApiKey)
        this.dataPreferences.putSync('openai_base_url', this.openaiBaseURL)
        this.dataPreferences.putSync('openai_model', this.openaiModel)
        this.dataPreferences.flush()
    }

    /**
     * 创建一条新的 `chat` 记录，并插入到数组的开头，不会刷新当前页面显示内容，需要调用 `showChat` 显示内容
     *
     * 使用 `Array.unshift()` 实现插入元素到数组开头
     */
    unshiftNewChatToList() {
        const newChatData = createChat(this.rdbStore, '新的聊天', this.defaultOpenaiModel)
        insertMessages(this.rdbStore, newChatData.id, defaultMessageDataList())
        this.chatDataList.unshift(newChatData)
    }

    /** 切换当前页面显示的 Chat 信息和消息列表，并更新 `currentChatId` */
    showChat(chatData: ChatData) {
        this.currentChatId = chatData.id
        this.messageDataList = getMessagesByChatID(this.rdbStore, chatData.id)
        this.navTitle = chatData.title
        this.openaiModel = chatData.model
    }

    build() {
        NavDestination() {
            MessageList({
                messageListScroller: this.messageListScroller,
                textAreaController: this.textAreaController,
            }).layoutWeight(1)
            BottomPanel({
                messageListScroller: this.messageListScroller,
                textAreaController: this.textAreaController,
            })
        }
        .title(this.navTitle)
        .onTouch(() => {
            this.pageHasTouch = true
        })
        .bindSheet($$this.isTextSelectModalShow, this.TextSelectModal, {
            title: { title: '选择文本', subtitle: '选取您喜欢的部分' },
            height: this.textSelectModalText.length > 150 ? SheetSize.LARGE : SheetSize.MEDIUM
        })
        .menus(navigationMenuItems(this))
    }

    @Builder
    TextSelectModal() {
        Column() {
            TextSelectModal({
                text: this.textSelectModalText
            })
        }
    }
}