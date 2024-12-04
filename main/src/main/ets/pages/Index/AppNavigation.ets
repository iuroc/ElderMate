import { SymbolGlyphModifier } from '@kit.ArkUI'
import { NavigationContent } from './NavigationContent'
import { PageMap } from './PageMap'

@Component
export struct AppNavigation {
    private toolbarItems = this.makeToolbarItems()
    private menuItems = this.makeMenuItems()
    @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack()
    /** 首页列表滚动控制器 */
    private appScroller = new Scroller()

    aboutToAppear(): void {

    }

    build() {
        Navigation(this.pathInfos) {
            NavigationContent({ scroller: this.appScroller })
        }
        .title(this.getGreeting())
        .hideBackButton(true)
        .menus(this.menuItems)
        .toolbarConfiguration(this.toolbarItems)
        .titleMode(NavigationTitleMode.Free)
        .onAppear(() => {
            this.pathInfos.pushPath({ name: 'Chat' })
        })
        .navDestination(PageMap)
    }

    /** 右上角菜单配置 */
    private makeMenuItems(): NavigationMenuItem[] {
        return [
            {
                value: '关于本项目',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.info_circle')),
                action: () => {
                    AlertDialog.show({
                        title: '关于本项目',
                        message: $r('app.string.about_project')
                    })
                }
            },
            { value: '分享软件', symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')) }
        ]
    }

    /** 根据当前时间返回问候语 */
    private getGreeting(): string {
        const now = new Date()
        const hours = now.getHours()
        let greeting = ''
        if (hours < 5) {
            greeting = '晚安~'
        } else if (hours < 12) {
            greeting = '早上好~'
        } else if (hours < 14) {
            greeting = '中午好~'
        } else if (hours < 18) {
            greeting = '下午好~'
        } else if (hours < 24) {
            greeting = '晚上好~'
        }
        return greeting
    }

    /** 底部工具栏配置 */
    private makeToolbarItems(): ToolbarItem[] {
        const that = this
        return [
            {
                value: '智老同行',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.house_fill')),
                action() {
                    that.appScroller.scrollTo({ xOffset: 0, yOffset: 0, animation: true })
                },
            },
            {
                value: '分享生活',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.pencil_and_card')),
                action() {
                    that.pathInfos.pushPath({ name: 'Share' })
                }
            },
            {
                value: '聊天助手',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.ellipsis_bubble')),
                action() {
                    that.pathInfos.pushPath({ name: 'Chat' })
                }
            },
            {
                value: '更多资讯',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.more')),
                action() {
                    that.pathInfos.pushPath({ name: 'More' })
                }
            },
            {
                value: '个人中心',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.person')),
                action() {
                    that.pathInfos.pushPath({ name: 'User' })
                }
            },
        ]
    }
}