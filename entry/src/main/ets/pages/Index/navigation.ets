import { TabsNameMap } from "./MyTabs"
import { SymbolGlyphModifier } from "@kit.ArkUI"

interface NavigationConfigItem {
    menuItems: NavigationMenuItem[]
    title: string
    titleMode: NavigationTitleMode
}

type NavigationConfig = Record<TabsNameMap, NavigationConfigItem>

/** 每个页面单独的导航配置 */
export const getNavigationConfig: () => NavigationConfig = () => {
    return {
        'home': {
            menuItems: [
                { value: '', symbolIcon: new SymbolGlyphModifier($r('sys.symbol.camera_mode_dualview')) }
            ],
            title: '智老同行',
            titleMode: NavigationTitleMode.Free
        },
        'community': {
            menuItems: [],
            title: '老年社区',
            titleMode: NavigationTitleMode.Mini
        },
        'assistant': {
            menuItems: [],
            title: '智能助手',
            titleMode: NavigationTitleMode.Mini
        },
        'news': {
            menuItems: [],
            title: '老年资讯',
            titleMode: NavigationTitleMode.Mini
        },
        'profile': {
            menuItems: [],
            title: '个人中心',
            titleMode: NavigationTitleMode.Free
        },
    }
}