import { SymbolGlyphModifier } from "@kit.ArkUI"

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        NavDestination() {

        }
        .menus(this.menuItems())
        .title('分享生活')
    }

    menuItems(): NavigationMenuItem[] {
        return [
            {
                value: '发布帖子',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil')),
                action: () => {
                    this.pathInfos.pushPath({ name: 'ShareEdit' })
                }
            }
        ]
    }
}

@Builder
export function PageBuilder() {
    Page()
}