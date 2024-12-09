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
import { ChatModel } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat/chat'
import { url } from '@kit.ArkTS'
import { promptAction } from '@kit.ArkUI'
import { ChatListDialog } from './ChatListDialog'
import { makeDefaultMessageDataList } from '../config/defaultMessageDataList'
import { RenameDialog } from './RenameDialog'

/**
 * 聊天助手页面组件
 *
 * ```
 * // 配置用户首选项
 * const dataPreferences = preferences.getPreferencesSync(getContext(), { name: 'chat' })
 *
 * // 设置 openai_api_key
 * dataPreferences.putSync('openai_api_key', `sk-xxx`)
 *
 * // 设置 openai_base_url
 * dataPreferences.putSync('openai_base_url', `https://api.openai.com/v1`)
 *
 * // 配置关系型数据库
 * const getRdbStore = async () => {
 *     return relationalStore.getRdbStore(getContext(), {
 *         name: 'chat.db',
 *         securityLevel: relationalStore.SecurityLevel.S1
 *     })
 * }
 *
 * // 使用组件
 * ChatPage({
 *     dataPreferences,
 *     getRdbStore,
 * })
 * ```
 */

@Component
export struct MainPage {
    @Prop defaultOpenaiModel: ChatModel = 'gpt-4o-mini'
    @Prop defaultOpenaiBaseURL: string = 'https://api.openai.com/v1'
    @Prop defaultThemeColor: BSColorNameMap = 'success'
    public messageListScroller = new Scroller()
    public settingDialogController: CustomDialogController = Object()
    public chatListDialogController: CustomDialogController = Object()
    public chatRenameDialogController: CustomDialogController = Object()
    /** 创建新对话时，默认的对话标题 */
    @Provide defaultChatTitle: string = ''
    @Provide inputMessage: string = ''
    @Provide messageDataList: MessageData[] = []
    @Provide isSelectMode: boolean = false
    /** 页面是否被触摸，从第一次触摸开始，该值由 `false` 变为 `true` */
    @Provide pageHasTouch: boolean = false
    @Provide isTextSelectModalShow: boolean = false
    @Provide textSelectModalText: string = ''
    /** 用户首选项 */
    @Require @Provide dataPreferences: preferences.Preferences = Object()
    @Require getRdbStore: () => Promise<relationalStore.RdbStore> = Object()
    /** 关系型数据库 */
    @Provide rdbStore: relationalStore.RdbStore = Object()
    /** 是否开启自动滚动到底部（当列表长度增加时） */
    @Provide autoScrollToBottom: boolean = true
    /** 是否显示 OpenAI 设置菜单 */
    @Provide openaiCanConfig: boolean = true
    @Provide openaiApiKey: string = ''
    @Provide openaiBaseURL: string = ''
    @Provide themeColor: BSColorNameMap = this.defaultThemeColor
    /** Chat 列表，按 ID 降序排列，第一项为最新记录 */
    @Provide chatDataList: ChatData[] = []
    @Provide currentChatIndex: number = 0
    @Provide isChatRequesting: boolean = false
    @Provide renameDialogChatDataIndex: number = 0
    /**
     * 创建新的聊天时，默认载入的聊天记录，可外部传参替换该数组。
     */
    @Provide defaultMessageDataList: MessageData[] = makeDefaultMessageDataList()

    public currentChat() {
        return this.chatDataList[this.currentChatIndex]
    }

    /**
     * 调用 `getRdbStore` 同步获取数据库连接，并调用 `initTables` 初始化创建数据表
     * @throws { BusinessError }
     */
    async initRdbRestore() {
        this.rdbStore = await this.getRdbStore()
        if (this.rdbStore.version == 0) {
            this.rdbStore.version = 1
            await initTables(this.rdbStore)
        }
    }

    /**
     * 从 resourceManager 载入字符串资源
     */
    initStringValue() {
        if (this.defaultChatTitle == '') {
            const resourceManager = getContext().resourceManager
            resourceManager.getStringValue($r('app.string.chat_assistant')).then(value => this.defaultChatTitle = value)
        }
    }

    /**
     * 初始化【设置】弹窗控制器
     */
    initSettingDialogController() {
        this.settingDialogController = new CustomDialogController({
            builder: SettingDialog({}),
            onWillDismiss: () => {
                try {
                    // 弹窗关闭时，保存 Preferences 中的 OpenAI 配置
                    if (this.openaiCanConfig) {
                        this.saveOpenAIConfig()
                    }
                    // 弹窗关闭时，更新数据库中当前 chat 的模型
                    this.updateCurrentChat({ model: this.chatDataList[this.currentChatIndex].model })
                    this.settingDialogController.close()
                    this.getUIContext().getFocusController().clearFocus()
                } catch (error) {
                    promptAction.showToast({ message: error.message })
                }
            },
        })
    }

    /**
     * 更新 `currentChatIndex` 对应的 chat 记录
     * @param values
     */
    updateCurrentChat(values: relationalStore.ValuesBucket) {
        const predicates = new relationalStore.RdbPredicates('chat')
        predicates.equalTo('id', this.chatDataList[this.currentChatIndex].id)
        this.rdbStore.updateSync(values, predicates)
    }

    aboutToAppear() {
        // 从 resourceManager 载入字符串资源
        this.initStringValue()
        // 从 Preferences 中载入 OpenAI 配置
        this.initPreferences()
        // 初始化【设置】弹窗控制器
        this.initSettingDialogController()
        // 初始化【重命名对话标题】弹窗控制器
        this.initChatRenameDialogController()
        // 初始化【历史消息】弹窗控制器
        this.initChatListDialogController()
        this.initRdbRestore().then(() => {
            this.chatDataList = getAllChatDataSorted(this.rdbStore)
            // 如果数据库中的 `chat` 表为空，则创建新的 `chat`
            if (this.chatDataList.length == 0) {
                this.unshiftNewChatToList()
            }
            this.currentChatIndex = Math.min(this.currentChatIndex, this.chatDataList.length - 1)
            this.showChat(this.currentChatIndex)
        })
    }

    // 初始化【重命名对话标题】弹窗控制器
    initChatRenameDialogController() {
        this.chatRenameDialogController = new CustomDialogController({
            builder: RenameDialog({}),
            showInSubWindow: true
        })
    }

    /** 初始化【历史消息】弹窗控制器 */
    initChatListDialogController() {
        this.chatListDialogController = new CustomDialogController({
            builder: ChatListDialog({
                showChat: index => {
                    this.showChat(index)
                },
                unshiftNewChatToList: () => {
                    this.unshiftNewChatToList()
                },
                controller: this.chatListDialogController,
                chatRenameDialogController: this.chatRenameDialogController
            }),
        })
    }

    /** 从 Preferences 中载入 OpenAI 配置
     *
     * - `openai_api_key` => `openaiApiKey`
     * - `openai_base_url` => `openaiBaseURL`
     * - `themeColor` => `themeColor`
     */
    initPreferences() {
        this.openaiApiKey = this.dataPreferences.getSync('openai_api_key', ``) as string
        this.openaiBaseURL = this.dataPreferences.getSync('openai_base_url', this.defaultOpenaiBaseURL) as string
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
        this.dataPreferences.flush()
    }

    /**
     * 创建一条新的 `chat` 记录，并插入到数组的开头，不会刷新当前页面显示内容，需要调用 `showChat` 显示内容
     *
     * 使用 `Array.unshift()` 实现插入元素到数组开头
     */
    unshiftNewChatToList() {
        const newChatData = createChat(this.rdbStore, this.defaultChatTitle, this.defaultOpenaiModel)
        insertMessages(this.rdbStore, newChatData.id, this.defaultMessageDataList)
        this.chatDataList.unshift(newChatData)
    }

    /** 切换当前页面显示的 Chat 信息和消息列表，并更新 `currentChatId` */
    showChat(index: number) {
        this.currentChatIndex = index
        this.messageDataList = getMessagesByChatID(this.rdbStore, this.chatDataList[this.currentChatIndex].id)
    }

    build() {
        NavDestination() {
            MessageList({
                messageListScroller: this.messageListScroller,
            }).layoutWeight(1)
            BottomPanel({
                messageListScroller: this.messageListScroller,
                updateCurrentChat: values => {
                    this.updateCurrentChat(values)
                }
            })
        }
        .title(this.chatDataList[this.currentChatIndex]?.title || this.defaultChatTitle)
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