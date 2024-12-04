import { getGreeting } from './utils'
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI'
import { AppList } from './AppList'

@Entry
@Component
struct Index {
    @State navTitle: string = ''
    @Provide pathInfos: NavPathStack = new NavPathStack()
    scroller = new Scroller()

    async aboutToAppear() {
        this.navTitle = await getGreeting()

        this.pathInfos.pushPath({ name: 'Chat' })
    }

    build() {
        Navigation(this.pathInfos) {
            AppList({ scroller: this.scroller })
        }
        .title(this.navTitle)
        .toolbarConfiguration(this.toolbarItems)
    }

    /** 底部工具栏配置 */
    private toolbarItems: ToolbarItem[] = [
        {
            value: '智老同行',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.house_fill')),
            action: () => {
                this.scroller.scrollToIndex(0, true)
            }
        },
        {
            value: '分享生活',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.pencil_and_card')),
            action: () => {
                this.pathInfos.pushPath({ name: 'Share' })
            }
        },
        {
            value: '聊天助手',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.ellipsis_bubble')),
            action: () => {
                this.pathInfos.pushPath({ name: 'Chat' })
            }
        },
        {
            value: '更多资讯',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.more')),
            action: () => {
                this.pathInfos.pushPath({ name: 'More' })
            }
        },
        {
            value: '个人中心',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.person')),
            action: () => {
                this.pathInfos.pushPath({ name: 'User' })
            }
        },
    ]
}