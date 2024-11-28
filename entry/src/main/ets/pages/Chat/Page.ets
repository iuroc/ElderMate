import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'
import { getSelectableItems, getSelectedItems, isAllSelected, MessageData, scrollToBottom } from './util'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'

@Component
export struct Page {
    @Consume pathInfos: NavPathStack
    @State title: string = ''
    /** 消息输入框内容 */
    @State inputValue: string = ''
    messageListScroller = new Scroller()
    /** 是否正在请求生成内容 */
    @State chatRequesting: boolean = false
    /** 是否处于多选模式 */
    @State selectMode: boolean = false
    textAreaController = new TextAreaController()
    /** 消息列表数据 */
    @State messageDataList: MessageData[] = this.getDefaultMessageDataList()
    systemPasteboard = pasteboard.getSystemPasteboard()
    @State textAreaLineCount: number = 0

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
                uuid: util.generateRandomUUID(false),
            },
            {
                role: 'user',
                content: '今天的天气怎么样？',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            },
            {
                role: 'assistant',
                content: '今天阳光明媚，气温在25度左右，非常适合外出活动。',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            },
            {
                role: 'user',
                content: '你有没有推荐的好书或者电影，可以分享一下你的感受吗？',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            },
            {
                role: 'assistant',
                content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            },
            {
                role: 'user',
                content: '你平时喜欢做哪些运动来保持健康？',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            },
            {
                role: 'assistant',
                content: '我平时最喜欢的运动是跑步和游泳。每周我都会尽量去跑步三次，大约30分钟到一个小时，感觉非常放松。而游泳则是我喜欢的夏季运动，它不仅锻炼全身肌肉，还能让我在水中感受到凉爽，尤其是在炎热的天气里。',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            }
        ]
        this.messageDataList.push(...tempAdds)
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column }) {
                this.MessageListContainer()
                Flex({
                    space: { main: LengthMetrics.vp(10) },
                    justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.End
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
    }

    /** 消息列表容器 */
    @Builder
    MessageListContainer() {
        Scroll(this.messageListScroller) {
            Column({ space: 20 }) {
                ForEach(this.messageDataList, (item: MessageData) => {
                    this.MessageItem(item)
                })
            }
            .margin(20)
        }
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.textAreaController.stopEditing()
            }
        })
        .align(Alignment.Top)
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
        .flexGrow(1)
    }

    @Builder
    SelectPanel() {
        Button(isAllSelected(this.messageDataList) ? '全不选' : '全选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).onClick(() => {
            this.changeAllSelectStatus(!isAllSelected(this.messageDataList))
        })
        Button('退出多选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).fontColor(Color.Red).onClick(() => {
            this.selectMode = false
        })
        Button('选中项操作').bindMenu([
            {
                value: '复制文本',
                icon: $r('app.media.copy'),
                action: () => {
                    const selectedItems = getSelectedItems(this.messageDataList)
                    const text = selectedItems.map(item => {
                        return `【${item.role}】\n${item.content.trim()}`
                    }).join(`\n${'-'.repeat(20)}\n`)
                    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
                    this.systemPasteboard.setData(data)
                        .then(() => {
                            promptAction.showToast({ message: `复制成功` })
                        })
                        .catch((error: BusinessError) => {
                            promptAction.showToast({ message: `复制失败：${error.message}` })
                        })
                        .finally(() => {
                            this.selectMode = false
                        })
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
                    getSelectedItems(this.messageDataList).forEach(item => {
                        this.deleteByUUID(item.uuid)
                    })

                    if (getSelectableItems(this.messageDataList).length == 0) {
                        this.selectMode = false
                    }
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

    /** 消息输入框 */
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
                this.textAreaLineCount = this.textAreaController.getTextContentLineCount()
            })
            .onEditChange(_isEditing => {
                if (_isEditing) {
                    // 进入编辑状态后，取消多选状态
                    this.selectMode = false
                }
                // 这里是个隐患，在软键盘抬起的同时让滚动区域滚到底部，需要设置一个时间去等待软键盘完全抬起，否则将无法正常跳转底部
                // 稳妥的做法是等待软键盘完全抬起，再滚动到底部，否则在软键盘完全抬起之前会滚动到错误的底部，软件就以为那里就是最底部了
                setTimeout(() => {
                    this.messageListScroller.scrollEdge(Edge.Bottom)
                }, 150)
            })
    }

    /** 消息发送按钮 */
    @Builder
    SendButton() {
        Column({ space: 10 }) {
            if (this.textAreaLineCount > 4) {
                Text(`${this.inputValue.trim().length}字`)
            }
            Button($r('app.string.ChatPage_send'), {
                stateEffect: this.inputValue.trim() != '',
                buttonStyle: this.inputValue.trim() != '' ? ButtonStyleMode.EMPHASIZED : ButtonStyleMode.NORMAL
            })
                .onClick(() => {
                    this.handleSendMessage()
                })
        }
        .flexShrink(0)
    }

    /** 消息列表中的头像 */
    @Builder
    MessageAvatar(item: MessageData) {
        SymbolGlyph(this.makeAvatarSymbolResource(item))
            .fontSize(30)
            .padding(3)
            .borderRadius(10)
            .flexShrink(0)
            .margin({ top: 2 })
            .shadow({ radius: 10, color: $r('sys.color.ohos_id_color_list_separator') })
    }

    /** 消息列表项，包含头像和消息气泡 */
    @Builder
    MessageItem(item: MessageData) {
        if (!item.hidden)
        Flex({
            space: { main: LengthMetrics.vp(10) },
            justifyContent: this.makeJustifyContent(item),
        }) {
            if (this.selectMode && item.role != 'info') {
                this.MessageCheckbox(item)
                Blank()
            }
            if (item.role == 'user') {
                this.MessageBubble(item)
                this.MessageAvatar(item)
            } else {
                this.MessageAvatar(item)
                this.MessageBubble(item)
            }
        }
        .onClick(() => {
            if (this.selectMode) {
                this.toggleSelected(item.uuid)
            }
        })
    }

    /** 消息多选项 */
    @Builder
    MessageCheckbox(item: MessageData) {
        Checkbox()
            .flexShrink(0)
            .select(item.selected)
            .onChange(() => {
                this.toggleSelected(item.uuid)
            })
            .shape(CheckBoxShape.ROUNDED_SQUARE)
    }

    /** 消息列表中的消息气泡 */
    @Builder
    MessageBubble(item: MessageData) {
        Text(item.content)
            .padding(10)
            .borderRadius(10)
            .backgroundColor(this.makeBubbleBGColor(item))
            .bindMenu(this.BubbleMenu(item))
            .onClick(() => {
                if (this.selectMode) {
                    this.toggleSelected(item.uuid)
                }
            })
    }

    @Builder
    BubbleMenu(item: MessageData) {
        if (item.role != 'info' && !this.selectMode)
        Menu() {
            ForEach(this.makeBubbleMenuElements(item), (element: MenuElement) => {
                MenuItem({
                    content: element.value,
                    symbolStartIcon: element.symbolIcon,
                    startIcon: element.icon,
                }).onClick(() => {
                    element.action()
                })
            })
        }
    }

    getDefaultMessageDataList(): MessageData[] {
        return [
            {
                role: 'info',
                content: '我是智能聊天助手，您可以问我任何问题~',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            }
        ]
    }

    toggleSelected(uuid: string) {
        for (let i = 0; i < this.messageDataList.length; i++) {
            if (uuid == this.messageDataList[i].uuid) {
                this.messageDataList[i].selected = !this.messageDataList[i].selected
                this.messageDataList[i] = JSON.parse(JSON.stringify(this.messageDataList[i]))
                return
            }
        }
    }

    makeJustifyContent(item: MessageData) {
        switch (item.role) {
            case 'user':
                return FlexAlign.End
            default:
                return FlexAlign.Start
        }
    }

    makeAvatarSymbolResource(item: MessageData): Resource {
        switch (item.role) {
            case 'user':
                return $r('sys.symbol.person_crop_circle_fill_1')
            case 'info':
                return $r('sys.symbol.flag')
            case 'system':
                return $r('sys.symbol.gearshape')
            case 'assistant':
                return $r('sys.symbol.lightbulb')
            default:
                throw new Error('role not allow')
        }
    }

    richEditorController = new RichEditorController()

    /** 聊天内容气泡的菜单配置 */
    makeBubbleMenuElements(item: MessageData): MenuElement[] {
        return [
            {
                value: '复制文本',
                icon: $r('app.media.copy'),
                action: () => {

                }
            },
            {
                value: '选择文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.selector')),
                action: () => {

                },
            },
            {
                value: '分享文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: () => {

                },
            },
            {
                value: this.selectMode ? '退出多选' : '批量选择',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_checkmask')),
                action: () => {
                    this.selectMode = !this.selectMode
                    if (this.selectMode) {
                        this.changeAllSelectStatus(false, item.uuid)
                    }
                },
            },
            {
                value: '发送到邮箱',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),
                action: () => {
                }
            },
            {
                value: '删除消息',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')),
                action: () => {
                    this.deleteByUUID(item.uuid)
                },
            },
        ]
    }

    /** 聊天内容气泡的背景颜色 */
    makeBubbleBGColor(item: MessageData): ResourceColor {
        switch (item.role) {
            case 'user':
                return Color.Pink
            default:
                return 'rgba(220,220,220,0.3)'
        }
    }

    handleSendMessage() {
        if (this.inputValue.trim() == '') {
            return
        }
        this.messageDataList.push({
            role: 'user',
            content: this.inputValue.trim(),
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
            hidden: false,
            selected: false,
        })
        this.inputValue = ''
        scrollToBottom(this.messageListScroller)
    }

    /** 右上角菜单项配置 */
    getMenuItems(): NavigationMenuItem[] {
        return this.selectMode ? [] : [
            {
                value: '清空当前聊天记录',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
                action: () => {
                    AlertDialog.show({
                        title: '提示',
                        message: '确定要删除当前窗口的所有聊天记录？',
                        buttons: [
                            {
                                value: '取消',
                                action() {
                                }
                            },
                            {
                                value: '确定',
                                action: () => {
                                    this.messageDataList = this.getDefaultMessageDataList()
                                },
                                fontColor: Color.Red
                            }
                        ]
                    })
                }
            },
            {
                value: '创建新对话',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus'))
            },
        ]
    }

    /** 设置全选或全不选，将例外项将设置为相反的值 */
    changeAllSelectStatus(selected: boolean, ...excepts: string[]) {
        this.messageDataList = this.messageDataList.map(item => {
            item.selected = excepts.includes(item.uuid) ? !selected : selected
            return item
        })
    }

    /** 删除指定 `UUID` 的消息 */
    deleteByUUID(uuid: string) {
        for (let i = 0; i < this.messageDataList.length; i++) {
            if (this.messageDataList[i].uuid == uuid) {
                this.messageDataList.splice(i, 1)
                return
            }
        }
    }
}

