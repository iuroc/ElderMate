import { getGreeting } from './utils'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { AppList } from './AppList'
import { common } from '@kit.AbilityKit'
import { BSColor } from '@iuroc/bootstrap5-color'
import { checkLoginInfo, User } from '../Login/utils'

@Entry
@ComponentV2
struct Index {
    @Local navTitle: string = ''
    @Provider() pathInfos: NavPathStack = new NavPathStack()
    @Provider() isAdmin: boolean = false
    scroller = new Scroller()
    @Local navigationShow: boolean = false

    async aboutToAppear() {
        this.navTitle = await getGreeting()
        this.mustCheckToken()
    }

    mustCheckToken() {
        checkLoginInfo().then(result => {
            this.navigationShow = true
            if (result.success) {
                this.isAdmin = result.data.role == 'admin'
                // this.pathInfos.pushPath({ name: 'More' }, false)
            } else {
                this.pathInfos.replacePath({ name: 'Login' }, false)
            }
        }).catch((error: Error) => {
            console.log(error.message)
            this.navigationShow = false
            AlertDialog.show({
                title: '服务器错误',
                message: '无法连接到服务器，请稍后重试。',
                primaryButton: {
                    value: '退出应用',
                    action: () => {
                        (getContext() as common.UIAbilityContext).terminateSelf()
                    },
                    fontColor: BSColor.danger
                },
                secondaryButton: {
                    value: '重试',
                    action: () => {
                        this.mustCheckToken()
                    }
                },
                autoCancel: false
            })
        })
    }

    build() {
        if (this.navigationShow) {
            Navigation(this.pathInfos) {
                AppList({ scroller: this.scroller })
            }
            .title(this.navTitle)
            .toolbarConfiguration(this.toolbarItems)
        } else {
            Column() {
                LoadingProgress().width(100).height(100)
            }
            .margin({ top: 100 })
            .width('100%')
        }
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