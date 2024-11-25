import { ComposeListItem, ContentItem, IconType, OperateItem } from '@kit.ArkUI'

interface ListItem {
    contentItem: ContentItem
    operateItem?: OperateItem
    onClick: (homeList: HomeList) => void
}

@Component
export struct HomeList {
    /** 入口页面的底部导航栏控制器 */
    @Require tabsController: TabsController = new TabsController()

    build() {
        List() {
            ForEach(this.listItems, (item: ListItem) => {
                ListItem() {
                    ComposeListItem({
                        contentItem: item.contentItem,
                        operateItem: item.operateItem || {
                            arrow: { value: $r('sys.media.ohos_ic_public_arrow_right') }
                        },
                    }).onClick(event => {
                        item.onClick(this)
                    })
                }
            })
        }
        .margin(10)
    }

    listItems: ListItem[] = [
        {
            contentItem: {
                primaryText: '用药提醒',
                secondaryText: '查看今天需要吃的药',
                iconStyle: IconType.SYSTEM_ICON,
                icon: $r('app.media.doc_plaintext_and_pencil'),
            },
            onClick(homeList: HomeList) {
            }
        },
        {
            contentItem: {
                primaryText: '紧急求助',
                secondaryText: '拨打紧急求助电话',
                iconStyle: IconType.SYSTEM_ICON,
                icon: $r('app.media.person_shield_fill')
            },
            onClick() {
            }
        },
        {
            contentItem: {
                primaryText: '我的医疗记录',
                secondaryText: '给医生看我的就诊记录',
                iconStyle: IconType.SYSTEM_ICON,
                icon: $r('app.media.doc_text_badge_checkmark')
            },
            onClick() {
            }
        },
        {
            contentItem: {
                primaryText: '我的个人信息',
                secondaryText: '展示我的个人信息给他人',
                iconStyle: IconType.SYSTEM_ICON,
                icon: $r('app.media.info_shield')
            },
            onClick() {
            }
        },
        {
            contentItem: {
                primaryText: '天气预报',
                secondaryText: '轻松查看今天的天气',
                iconStyle: IconType.SYSTEM_ICON,
                icon: $r('app.media.icloud')
            },
            onClick() {
            }
        },
        {
            contentItem: {
                primaryText: '智能聊天助手',
                secondaryText: '随时陪您聊天和解答问题',
                iconStyle: IconType.SYSTEM_ICON,
                icon: $r('app.media.doc_plaintext_and_pencil')
            },
            onClick(homeList) {
                homeList.tabsController.changeIndex(2)
            }
        },
    ]
}