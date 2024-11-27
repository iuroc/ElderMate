import { LengthMetrics, SymbolGlyphModifier, promptAction } from '@kit.ArkUI'

interface MessageItem {
    role: 'user' | 'assistant' | 'system' | 'info'
    content: string
    createTime: Date
}

@Component
export struct Page {
    @Consume pathInfos: NavPathStack
    @State title: string = ''
    @State inputValue: string = ''
    scroller = new Scroller()
    @State messageItems: MessageItem[] = [
        {
            role: 'info',
            content: '我是智能聊天助手，您可以问我任何问题',
            createTime: new Date()
        },
    ]

    async aboutToAppear() {
        const context = getContext()
        const resourceManager = context.resourceManager
        this.title = await resourceManager.getStringValue($r('app.string.ChatPage_title'))
    }

    @Builder
    MessageBody(item: MessageItem) {
        Text(item.content)
            .padding(10)
            .borderRadius(10)
            .backgroundColor(item.role == 'user' ? Color.Pink : 'rgba(220,220,220,0.3)')
            .textSelectable(TextSelectableMode.SELECTABLE_UNFOCUSABLE)
            .onClick(() => {
                AlertDialog.show({
                    title: '复制成功',
                    buttons: [
                        {
                            value: '确定',
                            action() {

                            }
                        }
                    ],
                    message: '已经将文本复制到您的剪切板'
                })
            })
    }

    @Builder
    MessageIcon(symbolIcon: Resource) {
        SymbolGlyph(symbolIcon)
            .fontSize(30)
            .borderRadius(10)
            .borderWidth(1)
            .flexShrink(0)
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column }) {
                Scroll(this.scroller) {
                    Column({ space: 20 }) {
                        ForEach(this.messageItems, (item: MessageItem) => {
                            Flex({
                                space: { main: LengthMetrics.vp(10) },
                                justifyContent: item.role == 'user' ? FlexAlign.End : FlexAlign.Start,
                            }) {
                                if (item.role == 'info') {
                                    this.MessageIcon($r('sys.symbol.camera_aperture_fill_circle'))
                                    this.MessageBody(item)
                                } else if (item.role == 'user') {
                                    this.MessageBody(item)
                                    this.MessageIcon($r('sys.symbol.camera_aperture_fill_circle'))
                                } else if (item.role == 'system') {
                                    this.MessageIcon($r('sys.symbol.calendar_fill'))
                                    this.MessageBody(item)
                                } else if (item.role == 'assistant') {
                                    this.MessageIcon($r('sys.symbol.passport'))
                                    this.MessageBody(item)
                                }
                            }
                        })
                    }
                    .margin(20)
                }
                .flexGrow(1)

                Flex({ space: { main: LengthMetrics.vp(10) } }) {
                    TextInput({ placeholder: $r("app.string.ChatPage_placeholder"), text: this.inputValue })
                        .onChange(value => {
                            this.inputValue = value
                        })
                    Button($r("app.string.ChatPage_send")).flexShrink(0)
                        .onClick(() => {
                            let str = this.inputValue
                            this.messageItems.push({
                                role: 'user',
                                content: str,
                                createTime: new Date()
                            })

                            this.inputValue = ''
                            this.scroller.scrollTo({
                                xOffset: 0,
                                yOffset: this.scroller.getItemRect(0).height,
                                animation: true
                            })

                            setTimeout(() => {
                                this.messageItems.push({
                                    role: 'assistant',
                                    content: str,
                                    createTime: new Date()
                                })
                                this.scroller.scrollTo({
                                    xOffset: 0,
                                    yOffset: this.scroller.getItemRect(0).height,
                                    animation: true
                                })
                            }, 1000)
                        })
                }
                .padding(10)
            }
        }
        .title(this.title)
        .menus(this.menuItems)
    }

    menuItems: NavigationMenuItem[] = [
        {
            value: '清空当前聊天记录',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
            action: () => {
                this.messageItems = this.messageItems.slice(0, 1)
            }
        },
        {
            value: '创建新对话',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus'))
        },
    ]
}
