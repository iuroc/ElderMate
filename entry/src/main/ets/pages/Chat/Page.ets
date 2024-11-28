import { LengthMetrics, SymbolGlyphModifier, promptAction } from '@kit.ArkUI'
import { changeAllSelectStatus, deleteByUUID, MessageData, MessageList, quitSelectMode } from './MessageList'
import { util } from '@kit.ArkTS'

@Component
export struct Page {
    @Consume pathInfos: NavPathStack
    @State title: string = ''
    /** 消息输入框内容 */
    @State inputValue: string = ''
    scroller = new Scroller()
    @State chatRequesting: boolean = false
    @State selectMode: boolean = false
    textAreaController = new TextAreaController()

    // 默认的消息列表数据
    getDefaultMessageDataList(): MessageData[] {
        return [
            {
                role: 'info',
                content: '我是智能聊天助手，您可以问我任何问题~',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false)
            }
        ]
    }

    isAllSelected() {
        return this.messageDataList.filter(item =>!item.selected).length == 0
    }

    /** 消息列表数据 */
    @State messageDataList: MessageData[] = this.getDefaultMessageDataList()

    async aboutToAppear() {
        const context = getContext()
        const resourceManager = context.resourceManager
        this.title = await resourceManager.getStringValue($r('app.string.ChatPage_title'))

        const tempAdds: MessageData[] = [
            {
                role: 'system',
                content: '你是一个智能老年人生活助手，你的职责是帮助老年人解答生活中遇到的各种问题，并以亲切有趣的风格生成适合老年人的回答。',
                createTime: new Date(),
                hidden: true,
                uuid: util.generateRandomUUID(false)
            },
            {
                role: 'user',
                content: '今天的天气怎么样？',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false)
            },
            {
                role: 'assistant',
                content: '今天阳光明媚，气温在25度左右，非常适合外出活动。',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false)
            },
            {
                role: 'user',
                content: '你有没有推荐的好书或者电影，可以分享一下你的感受吗？',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false)
            },
            {
                role: 'assistant',
                content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false)
            },
            {
                role: 'user',
                content: '你平时喜欢做哪些运动来保持健康？',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false)
            },
            {
                role: 'assistant',
                content: '我平时最喜欢的运动是跑步和游泳。每周我都会尽量去跑步三次，大约30分钟到一个小时，感觉非常放松。而游泳则是我喜欢的夏季运动，它不仅锻炼全身肌肉，还能让我在水中感受到凉爽，尤其是在炎热的天气里。',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false)
            }
        ]
        this.messageDataList.push(...tempAdds)
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column }) {
                MessageList({
                    scroller: this.scroller,
                    messageDataList: this.messageDataList,
                    selectMode: this.selectMode,
                    textAreaController: this.textAreaController
                }).flexGrow(1)
                Flex({
                    space: { main: LengthMetrics.vp(10) },
                    justifyContent: FlexAlign.Center
                }) {
                    if (this.selectMode) {
                        this.SelectPanel()
                    } else {
                        this.MessageInput()
                        this.SendButton()
                    }
                }
                .padding(10)
            }
        }
        .title(this.title)
        .menus(this.getMenuItems())
        .onShown(() => {
            this.scroller.scrollEdge(Edge.Bottom)
        })
    }

    @Builder
    SelectPanel() {
        Button(this.isAllSelected() ? '全不选' : '全选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).onClick(() => {
            changeAllSelectStatus(this, !this.isAllSelected())
        })
        Button('退出多选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).fontColor(Color.Red).onClick(() => {
            quitSelectMode(this)
        })
        Button('选中项操作').bindMenu([
            {
                value: '复制文本',
                icon: $r('app.media.copy'),
                action: () => {

                }
            },
            {
                value: '分享文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: () => {

                },
            },
            {
                value: '删除消息',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')),
                action: () => {
                    this.messageDataList.filter(item => item.selected)
                        .forEach(item => {
                            if (item.selected) {
                                deleteByUUID(this, item.uuid)
                            }
                        })
                }
            },
            {
                value: '发送到邮箱',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),
                action: () => {
                }
            },
        ])
    }

    /**
     * 消息输入框
     */
    @Builder
    MessageInput() {
        TextArea({
            placeholder: $r("app.string.ChatPage_placeholder"),
            text: this.inputValue,
            controller: this.textAreaController
        })
            .enableKeyboardOnFocus(false)
            .onChange(value => {
                this.inputValue = value
            })
            .onEditChange(_isEditing => {
                if (_isEditing) {
                    // 进入编辑状态后，取消多选状态
                    this.selectMode = false
                }
                // 这里是个隐患，在软键盘抬起的同时让滚动区域滚到底部，需要设置一个时间去等待软键盘完全抬起，否则将无法正常跳转底部
                // 稳妥的做法是等待软键盘完全抬起，再滚动到底部，否则在软键盘完全抬起之前会滚动到错误的底部，软件就以为那里就是最底部了
                setTimeout(() => {
                    this.scroller.scrollEdge(Edge.Bottom)
                }, 200)
            })
    }

    /**
     * 消息发送按钮
     */
    @Builder
    SendButton() {
        Button($r('app.string.ChatPage_send'), {
            stateEffect: this.inputValue.trim() != '',
            buttonStyle: this.inputValue.trim() != '' ? ButtonStyleMode.EMPHASIZED : ButtonStyleMode.NORMAL
        }).flexShrink(0)
            .onClick(() => {
                this.handleSendMessage()
            })
    }

    handleSendMessage() {
        if (this.inputValue.trim() == '') {
            return
        }
        this.messageDataList.push({
            role: 'user',
            content: this.inputValue.trim(),
            createTime: new Date(),
            uuid: util.generateRandomUUID(false)
        })
        this.inputValue = ''
        scrollToBottom(this.scroller)
    }

    /**
     * 右上角菜单项配置
     */
    getMenuItems(): NavigationMenuItem[] {
        return this.selectMode ? [] : [
            {
                value: '清空当前聊天记录',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
                action: () => {
                    this.messageDataList = this.messageDataList.slice(0, 1)
                }
            },
            {
                value: '创建新对话',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus'))
            },
        ]
    }
}

/**
 * 滚动到底部
 * @param scroller
 */
function scrollToBottom(scroller: Scroller, animation = true) {
    scroller.scrollTo({
        xOffset: 0,
        yOffset: scroller.getItemRect(0).height,
        animation
    })
}
