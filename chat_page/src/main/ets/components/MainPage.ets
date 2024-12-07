import { BSColorNameMap } from '@iuroc/bootstrap5-color'
import { BottomPanel } from './BottomPanel'
import { MessageList } from './MessageList'
import { MessageData } from './MessageListItem'
import { TextSelectModal } from './TextSelectModal'
import { navigationMenuItems } from '../config/navigationMenuItems'
import { SettingDialog } from './SettingDialog'
import { preferences, relationalStore } from '@kit.ArkData'
import {
    getLatestChat,
    initTables,
    createChat,
    insertMessages,
    ChatData,
    getMessagesByChatID,
    getAllChatData,
    createNewChatForPage,
    sortChatList
} from '../utils/db'
import { BusinessError } from '@kit.BasicServicesKit'
import { ChatModel } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat/chat'
import { url } from '@kit.ArkTS'
import { promptAction } from '@kit.ArkUI'
import { defaultMessageDataList } from '../config/defaultMessageDataList'
import { exampleMessageDataList } from '../config/exampleMessageDataList'

@Component
export struct MainPage {
    @State navTitle: string = ''
    @Provide inputMessage: string = ''
    @Provide messageDataList: MessageData[] = []
    @Provide themeColor: BSColorNameMap = 'success'
    @Provide isSelectMode: boolean = false
    /** 页面是否被触摸，从第一次触摸开始，该值由 `false` 变为 `true` */
    @Provide pageHasTouch: boolean = false
    public messageListScroller = new Scroller()
    public textAreaController = new TextAreaController()
    @Provide isTextSelectModalShow: boolean = false
    @Provide textSelectModalText: string = ''
    settingDialogController = new CustomDialogController({
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
    /** 用户首选项 */
    @Require @Provide dataPreferences: preferences.Preferences = Object()
    /** 关系型数据库 */
    @Provide rdbStore: relationalStore.RdbStore = Object()
    @Require getRdbStore: () => Promise<relationalStore.RdbStore> = Object()
    /** 是否开启自动滚动到底部（当列表长度增加时） */
    @Provide autoScrollToBottom: boolean = true
    /** 是否显示 OpenAI 设置菜单 */
    @Provide openaiCanConfig: boolean = true
    @Provide openaiApiKey: string = ''
    @Provide openaiBaseURL: string = ''
    defaultOpenaiModel: ChatModel = 'gpt-4o-mini'
    @Provide openaiModel: ChatModel = this.defaultOpenaiModel
    defaultOpenaiBaseURL = 'https://api.openai.com/v1'
    /** Chat 列表，按 ID 降序排列，第一项为最新记录 */
    @Provide chatDataList: ChatData[] = []

    /**
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

    initStringValue() {
        const resourceManager = getContext().resourceManager
        resourceManager.getStringValue($r('app.string.chat_assistant')).then(value => this.navTitle = value)
    }

    aboutToAppear() {
        this.initStringValue()
        this.initOpenAI()
        this.initRdbRestore().catch((error: BusinessError) => {
            console.error(error.message)
        }).then(() => {
            this.chatDataList = getAllChatData(this.rdbStore)
            if (this.chatDataList.length == 0) {
                createNewChatForPage(this.rdbStore, this.chatDataList, this.defaultOpenaiModel)
            }
            this.messageDataList = getMessagesByChatID(this.rdbStore, sortChatList(this.chatDataList)[0].id)
            this.navTitle = this.chatDataList[0].title
            // 将当前页面的模型类型更新为数据库中最新 chat 的
            this.openaiModel = this.chatDataList[0].model
        })
        this.themeColor = this.dataPreferences.getSync('theme_color_name', 'success') as BSColorNameMap
    }

    /** 载入 OpenAI 配置 */
    initOpenAI() {
        this.openaiApiKey = this.dataPreferences.getSync(
            'openai_api_key',
            `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`
        ) as string
        this.openaiBaseURL = this.dataPreferences.getSync('openai_base_url', this.defaultOpenaiBaseURL) as string
        this.openaiModel = this.dataPreferences.getSync('openai_model', 'gpt-4o-mini') as ChatModel

        // 测试值
        // this.openaiApiKey = `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`
        // this.openaiBaseURL = `https://openkey.cloud/v1`
        // this.openaiModel = `gpt-4o-mini`
    }

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