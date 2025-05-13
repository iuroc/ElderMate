import { IconType, ContentItem, OperateItem, ComposeListItem, } from '@kit.ArkUI'
import { getUserInfo, User } from '../Login/utils'
import { ShareLink } from '../More/Page'

@ComponentV2
export struct AppList {
    @Consumer() pathInfos: NavPathStack = Object()
    @Require @Param scroller: Scroller = Object()
    @Consumer() isAdmin: boolean = false

    aboutToAppear(): void {
    }

    build() {
        List({ scroller: this.scroller }) {
            ForEach(this.makeListItemDataList(), (listItemData: ListItemData, index) => {
                ListItem() {
                    ComposeListItem({
                        contentItem: listItemData.contentItem,
                        operateItem: listItemData.operateItem
                    }).onClick(listItemData.onClick)
                        .margin({
                            bottom: index == this.makeListItemDataList().length - 1 ? 20 : 0,
                            left: 10,
                            right: 10
                        })
                }
            })
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }

    private makeListItemDataList(): ListItemData[] {
        return (this.isAdmin
            ? [
                {
                    contentItem: {
                        primaryText: '用户管理',
                        secondaryText: '查看和管理用户列表',
                        iconStyle: IconType.HEAD_SCULPTURE,
                        icon: $r('app.media.gearshape'),
                    },
                    onClick: () => {
                        this.pathInfos.pushPath({ name: 'UserControl' })
                    }
                },
                {
                    contentItem: {
                        primaryText: '帖子审核',
                        secondaryText: '支持删除不合规的帖子',
                        iconStyle: IconType.HEAD_SCULPTURE,
                        icon: $r('app.media.trash'),
                    },
                    onClick: () => {
                        this.pathInfos.pushPath({ name: 'Share' })
                    }
                }
            ] as ListItemData[]
            : [] as ListItemData[]).concat([
            {
                contentItem: {
                    primaryText: '用药提醒',
                    secondaryText: '查看今天需要吃的药',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.calendar_badge_clock'),
                },
                onClick: () => {
                    this.pathInfos.pushPath({ name: 'MedAlert' })
                }
            },
            {
                contentItem: {
                    primaryText: '紧急求助',
                    secondaryText: '拨打紧急求助电话',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.person_shield_fill')
                },
                onClick: () => {
                    this.pathInfos.pushPath({ name: 'CallHelp' })
                }
            },
            {
                contentItem: {
                    primaryText: '我的就诊记录',
                    secondaryText: '给医生看我的就诊记录',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.doc_text_badge_checkmark'),
                },
                onClick: () => {
                    this.pathInfos.pushPath({ name: 'MedRecord' })
                }
            },
            {
                contentItem: {
                    primaryText: '我的个人信息',
                    secondaryText: '展示我的个人信息给他人',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.info_shield')
                },
                onClick: () => {
                    this.pathInfos.pushPath({ name: 'MyInfo' })
                }
            },
            {
                contentItem: {
                    primaryText: '天气预报',
                    secondaryText: '轻松查看今天的天气',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.icloud')
                },
                onClick: () => {
                    this.pathInfos.pushPath({
                        name: 'WebView', param: {
                            href: 'https://xw.tianqi.qq.com/',
                            title: '天气预报'
                        } as ShareLink
                    })
                }
            },
            {
                contentItem: {
                    primaryText: '智能聊天助手',
                    secondaryText: '随时陪您聊天和解答问题',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.ellipsis_bubble')
                },
                operateItem: {
                    text: '状态管理V1'
                },
                onClick: () => this.pathInfos.pushPath({ name: 'Chat' })
            },
            {
                contentItem: {
                    primaryText: '智能聊天助手',
                    secondaryText: '随时陪您聊天和解答问题',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.ellipsis_bubble')
                },
                operateItem: {
                    text: '状态管理V2'
                },
                onClick: () => this.pathInfos.pushPath({ name: 'ChatV2' })
            },
            {
                contentItem: {
                    primaryText: '社区活动',
                    secondaryText: '参加或投稿社区活动',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.flag')
                },
                onClick: () => {
                    this.pathInfos.pushPath({ name: 'Share' })
                }
            },
        ])
    }
}

interface ListItemData {
    contentItem: ContentItem
    operateItem?: OperateItem
    onClick: (event: ClickEvent) => void
}