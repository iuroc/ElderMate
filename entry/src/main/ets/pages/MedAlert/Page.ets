import { SymbolGlyphModifier, SymbolSpanModifier } from "@kit.ArkUI"

/**
 * MedAlert 用药提醒模块
 */
@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        NavDestination() {

        }
        .title('用药提醒')
        .menus(this.menuItems())
    }

    menuItems(): NavigationMenuItem[] {
        return [{
            value: '新增吃药',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
            action: () => {
                this.pathInfos.pushPath({ name: 'AddMed' })
            }
        }]
    }
}

@Builder
export function PageBuilder() {
    Page()
}