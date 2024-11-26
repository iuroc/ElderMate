import { TabsNameMap } from "./MyTabs"
import { SymbolGlyphModifier } from "@kit.ArkUI"

/** 每个页面单独的导航配置 */
export const getNavigationConfig: () => NavigationConfig = () => {
    return {
        'home': {
            menuItems: [
            ],
            title: '智老同行',
            titleMode: NavigationTitleMode.Free
        },
        'community': {
            menuItems: [
                { value: '发表帖子', symbolIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil')) }
            ],
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

interface NavigationConfigItem {
    menuItems: NavigationMenuItem[]
    title: string
    titleMode: NavigationTitleMode
}

type NavigationConfig = Record<TabsNameMap, NavigationConfigItem>