import { BSColorNameMap } from '@iuroc/bootstrap5-color'
import { exampleMessageDataList } from '../config/exampleMessageDataList'
import { BottomPanel } from './BottomPanel'
import { defaultMessageDataList } from '../config/defaultMessageDataList'
import { MessageList } from './MessageList'
import { MessageData } from './MessageListItem'
import { BooleanValue } from '../utils/utils'
import { TextSelectModal } from './TextSelectModal'
import { navigationMenuItems } from '../config/navigationMenuItems'
import { SettingDialog } from './SettingDialog'

@Component
export struct MainPage {
    @State navTitle: string = ''
    @State inputMessage: string = ''
    @Provide messageDataList: MessageData[] = []
    @Provide themeColor: BSColorNameMap = 'success'
    @Provide isSelectMode: boolean = false
    /** 页面是否被触摸，从第一次触摸开始，该值由 `false` 变为 `true` */
    pageHasTouch = new BooleanValue()
    messageListScroller = new Scroller()
    textAreaController = new TextAreaController()
    @Provide isTextSelectModalShow: boolean = false
    @Provide textSelectModalText: string = ''
    settingDialogController = new CustomDialogController({
        builder: SettingDialog({}),
    })

    async aboutToAppear() {
        this.navTitle = await getContext().resourceManager.getStringValue($r('app.string.chat_assistant'))
        this.messageDataList = defaultMessageDataList().concat(exampleMessageDataList())
    }

    build() {
        NavDestination() {
            MessageList({
                messageListScroller: this.messageListScroller,
                // nextSizeChangeNeedScrollToBottom: this.nextSizeChangeNeedScrollToBottom,
                textAreaController: this.textAreaController,
                pageHasTouch: this.pageHasTouch
            }).layoutWeight(1)
            BottomPanel({
                messageListScroller: this.messageListScroller,
                inputMessage: this.inputMessage,
                textAreaController: this.textAreaController,
                // nextSizeChangeNeedScrollToBottom: this.nextSizeChangeNeedScrollToBottom
            })
        }
        .title(this.navTitle)
        .onTouch(() => {
            this.pageHasTouch.value = true
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

