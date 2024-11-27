import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI'

interface MessageItem {
    role: 'user' | 'assistant' | 'system'
    content: string
}

@Component
export struct Page {
    @Consume pathInfos: NavPathStack
    @State title: string = ''
    @State messageItems: MessageItem[] = []

    async aboutToAppear() {
        const context = getContext()
        const resourceManager = context.resourceManager
        this.title = await resourceManager.getStringValue($r('app.string.ChatPage_title'))
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column }) {
                Flex() {

                }
                .backgroundColor(Color.Pink)
                .flexGrow(1)

                Flex({ space: { main: LengthMetrics.vp(10) } }) {
                    TextInput({ placeholder: $r("app.string.ChatPage_placeholder") })
                    Button($r("app.string.ChatPage_send")).flexShrink(0)
                }
            }
            .height('100%')
            .padding({
                left: 10,
                right: 10
            })
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
