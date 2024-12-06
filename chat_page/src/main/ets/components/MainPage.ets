import { BSColorNameMap } from '@iuroc/bootstrap5-color'
import { exampleMessageDataList } from '../config/exampleMessageDataList'
import { BottomPanel } from './BottomPanel'
import { defaultMessageDataList } from '../config/defaultMessageDataList'
import { MessageList } from './MessageList'
import { MessageData } from './MessageListItem'
import { TextSelectModal } from './TextSelectModal'
import { navigationMenuItems } from '../config/navigationMenuItems'
import { SettingDialog } from './SettingDialog'
import { preferences, relationalStore } from '@kit.ArkData'
import { initTables } from '../utils/db'
import { BusinessError } from '@kit.BasicServicesKit'
import { ChatModel } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat/chat'
import { getOpenaiConfig } from '../utils/utils'

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
    @Provide openaiModel: ChatModel = 'gpt-4o-mini'

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
        // await copyDatabaseDir().catch((error: BusinessError) => {
        //     console.log('copyDatabaseDir', error)
        // })
    }

    initStringValue() {
        const resourceManager = getContext().resourceManager
        resourceManager.getStringValue($r('app.string.chat_assistant')).then(value => this.navTitle = value)
    }

    aboutToAppear() {
        this.initStringValue()
        this.initRdbRestore().catch((error: BusinessError) => {
            console.error(error.message)
        })
        this.themeColor = this.dataPreferences.getSync('theme_color_name', 'success') as BSColorNameMap
        this.messageDataList = defaultMessageDataList().concat(exampleMessageDataList())
        this.initOpenAI()
    }

    /** 载入 OpenAI 配置 */
    initOpenAI() {
        const openaiConfig = getOpenaiConfig(this.dataPreferences)
        this.openaiApiKey = openaiConfig.apiKey as string
        this.openaiBaseURL = openaiConfig.baseURL as string

        // 测试值
        this.openaiApiKey = `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`
        this.openaiBaseURL = `https://openkey.cloud/v1`
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