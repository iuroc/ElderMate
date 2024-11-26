import { SymbolGlyphModifier } from '@kit.ArkUI'

@Component
export struct AppNavigation {
    toolbarItems = this.makeToolbarItems()
    menuItems = this.makeMenuItems()
    title: ResourceStr = $r('app.string.EntryAbility_label')
    @Provide pathInfos: NavPathStack = new NavPathStack()

    aboutToAppear(): void {

    }

    build() {
        Navigation(this.pathInfos) {

        }
        .title(this.title)
        .hideBackButton(true)
        .menus(this.menuItems)
        .toolbarConfiguration(this.toolbarItems)
        .navDestination(this.PageMap)
    }

    @Builder
    PageMap(name: string) {
        if (name == 'home') {
            NavDestination() {
                Button('智老同行').onClick(() => {
                    // this.pathInfos.pop()
                    console.log('iuroc', JSON.stringify(this.pathInfos.getParamByName('name')))
                })
            }
        } else if (name == 'share') {
            NavDestination() {
                Button('分享生活')
            }
        } else if (name == 'chat') {
            NavDestination() {
                Button('聊天助手')
            }
        } else if (name == 'more') {
            NavDestination() {
                Button('更多资讯')
            }
        } else if (name == 'user') {
            NavDestination() {
                Button('个人中心')
            }
        }
    }

    makeMenuItems(): NavigationMenuItem[] {
        return [
            { value: '分享软件', symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')) }
        ]
    }

    makeToolbarItems(): ToolbarItem[] {
        const that = this
        return [
            {
                value: '智老同行',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.house')),
                action() {
                    that.pathInfos.pushPath({ name: 'home', param: 'Hello World' })
                }
            },
            {
                value: '分享生活',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.pencil_and_card')),
            },
            {
                value: '聊天助手',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.ellipsis_bubble'))
            },
            {
                value: '更多资讯',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.more'))
            },
            {
                value: '个人中心',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.person'))
            },
        ]
    }
}

