import { SymbolGlyphModifier } from '@kit.ArkUI'
import { Page as SharePage } from '../Share/Page'
import { Page as ChatPage } from '../Chat/Page'
import { Page as MorePage } from '../More/Page'
import { Page as UserPage } from '../User/Page'
import { NavigationContent } from './NavigationContent'

@Component
export struct AppNavigation {
    private toolbarItems = this.makeToolbarItems()
    private menuItems = this.makeMenuItems()
    @Provide('AppNavigation') pathInfos: NavPathStack = new NavPathStack()
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
        .navDestination(this.PageMap)
        .titleMode(NavigationTitleMode.Free)
    }

    /** 子页面配置 */
    @Builder
    PageMap(name: string, _param: string) {
        if (name == 'share') {
            SharePage()
        } else if (name == 'chat') {
            ChatPage()
        } else if (name == 'more') {
            MorePage()
        } else if (name == 'user') {
            UserPage()
        }
    }

    /** 右上角菜单配置 */
    private makeMenuItems(): NavigationMenuItem[] {
        return [
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
                    that.appScroller.scrollTo({ xOffset: 0, yOffset: 0 })
                },
            },
            {
                value: '分享生活',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.pencil_and_card')),
                action() {
                    that.pathInfos.pushPath({ name: 'share' })
                }
            },
            {
                value: '聊天助手',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.ellipsis_bubble')),
                action() {
                    that.pathInfos.pushPath({ name: 'chat' })
                }
            },
            {
                value: '更多资讯',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.more')),
                action() {
                    that.pathInfos.pushPath({ name: 'more' })
                }
            },
            {
                value: '个人中心',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.person')),
                action() {
                    that.pathInfos.pushPath({ name: 'user' })
                }
            },
        ]
    }
}