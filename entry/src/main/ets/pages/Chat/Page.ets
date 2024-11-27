import { LengthMetrics, SymbolGlyphModifier, KeyboardAvoidMode } from '@kit.ArkUI'

interface MessageItem {
    role?: 'user' | 'assistant' | 'system'
    type: 'message' | 'log'
    content: string
    createTime: Date
}

@Component
export struct Page {
    @Consume pathInfos: NavPathStack
    @State title: string = ''
    @State inputValue: string = ''
    @State messageItems: MessageItem[] = [
        {
            type: 'log',
            content: '我是智能聊天助手，您可以问我任何问题哦',
            createTime: new Date()
        },
        {
            type: 'message',
            role: 'user',
            content: '太阳系有多少颗行星',
            createTime: new Date()
        },
        {
            type: 'message',
            role: 'assistant',
            content: `太阳系有八颗行星。按照离太阳由近及远的顺序，它们分别是：水星、金星、地球、火星、木星、土星、天王星、海王星，此前，冥王星曾被认为是第九颗行星，但在2006年，国际天文学联合会将冥王星重新分类为“矮行星”。`,
            createTime: new Date()
        },
        {
            type: 'message',
            role: 'user',
            content: '金星的特点是什么',
            createTime: new Date()
        },
        {
            type: 'message',
            role: 'assistant',
            content: `金星有许多独特的特点，使其在太阳系中引人注目：
大小和结构：金星与地球大小相近，且结构也类似，包括铁质核心、岩石地幔和硅酸盐地壳，因此常被称为地球的“姊妹行星”。
厚重的大气层：金星的大气层浓厚且主要由二氧化碳组成，并含有少量的氮气。大气压强非常高，是地球的约92倍。
极端的表面温度：由于强烈的温室效应，金星表面的平均温度高达约465摄氏度，是所有行星中最高的，足以融化铅。
反向自转：金星自转方向与大多数其他行星相反，从东向西，称为逆行自转。此外，它的自转非常缓慢，一天相当于地球上的243天，而其公转周期为约225天，这意味着金星上一天比一年还长。
厚重的云层：金星被浓密的云层覆盖，这些云主要由硫酸组成，反射了太阳大部分的光，使金星成为夜空中最亮的天体之一。
无天然卫星：不同于地球，金星没有天然卫星或环绕其运行的月球。
这些特点使得金星成为科学家研究行星大气、气候变化及行星演化的重要对象。`,
            createTime: new Date()
        }
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
                Scroll() {
                    Column({ space: 20 }) {
                        ForEach(this.messageItems, (item: MessageItem) => {
                            Flex({
                                space: { main: LengthMetrics.vp(10) },
                                justifyContent: item.type == 'message' && item.role == 'user'
                                    ? FlexAlign.End : FlexAlign.Start,
                            }) {
                                if (item.type == 'log') {
                                    this.MessageIcon($r('sys.symbol.camera_aperture_fill_circle'))
                                    this.MessageBody(item)
                                } else if (item.type == 'message') {
                                    if (item.role == 'user') {
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
                            this.messageItems.push({
                                type: 'message',
                                role: 'user',
                                content: ''
                            })
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
        },
        {
            value: '创建新对话',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus'))
        },
    ]
}
