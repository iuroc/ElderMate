import { BSColor } from "@iuroc/bootstrap5-color"
import { display, promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { apiOrigin } from "../../common/config"
import { getSharePostList, ISharePost, iSharePostToObservedV2, shareLike } from "./utils"
import { filePreview } from "@kit.PreviewKit"
import { extname, extToMime } from "../../common/utils"
import { BusinessError, request } from "@kit.BasicServicesKit"
import { fileIo, fileUri } from "@kit.CoreFileKit"

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local posts: SharePostObservedV2[] = []
    @Local imageHeight: number = 0
    columCount = 3
    columGap = 5

    aboutToAppear(): void {
        const defaultDisplay = display.getDefaultDisplaySync()
        this.imageHeight = (px2vp(defaultDisplay.width) - 30 - 10 - 40
            - (this.columCount - 1) * this.columGap) / 3
    }

    build() {
        NavDestination() {
            List() {
                ForEach(this.posts, (post: SharePostObservedV2, index) => {
                    ListItem() {
                        Row({ space: 10 }) {
                            this.Cover($r('app.media.daimaozixiangsuren'))
                            this.Body(post)
                        }
                        .alignItems(VerticalAlign.Top)
                    }
                    .padding(15)
                })
            }
            .width('100%')
            .height('100%')
            .divider({
                strokeWidth: 1
            })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .menus(this.menuItems())
        .title('分享生活')
        .onWillAppear(() => {
        })
        .onWillAppear(() => {
            getSharePostList(0, 120).then(list => {
                this.posts.push(...iSharePostToObservedV2(list))
            })
        })
    }

    @Builder
    Cover(src: ResourceStr) {
        Image(src).width(40).height(40)
            .borderRadius(10)
            .flexShrink(0)
    }

    @Builder
    Body(post: SharePostObservedV2) {
        Column({ space: 10 }) {
            Text(post.user.nickName)
                .fontColor(BSColor.primary_text_emphasis)
                .fontWeight(FontWeight.Regular)
            Text(post.content)
            if (post.images.length > 0) {
                Grid() {
                    ForEach(post.images, (image: string, index) => {
                        GridItem() {
                            Image(apiOrigin + image)
                                .height(this.imageHeight)
                                .width('100%')
                                .onClick(() => {
                                    const filePath = getContext().filesDir + image.replaceAll('/', '')
                                    const preview = () => {
                                        filePreview.openPreview(getContext(), {
                                            uri: fileUri.getUriFromPath(filePath),
                                            title: '预览图片',
                                            mimeType: extToMime(extname(image))[0]
                                        })
                                    }
                                    if (!fileIo.accessSync(filePath)) {
                                        request.downloadFile(getContext(), {
                                            url: apiOrigin + image,
                                            filePath
                                        }).then(task => {
                                            task.on('complete', () => {
                                                preview()
                                            })
                                        })
                                    } else {
                                        preview()
                                    }
                                })
                        }
                    })
                }
                .columnsTemplate(new Array(this.columCount).fill('1fr').join(' '))
                .columnsGap(this.columGap)
                .rowsGap(this.columGap)
            }
            Row({ space: 10 }) {
                Text(new Date(post.createTime).toLocaleString())
                    .fontColor(BSColor.secondary)
                    .fontSize(14)
                    .fontWeight(FontWeight.Normal)
                    .layoutWeight(1)
                Button() {
                    if (post.isLike) {
                        SymbolGlyph($r('sys.symbol.heart_fill')).fontSize(18).fontColor([BSColor.danger])
                    } else {
                        SymbolGlyph($r('sys.symbol.heart')).fontSize(18)
                    }
                }
                .padding(6)
                .buttonStyle(ButtonStyleMode.NORMAL)
                .onClick(() => {
                    shareLike(post.id).then(result => {
                        post.isLike = result
                    }).catch((error: Error) => {
                        promptAction.showToast({ message: error.message })
                    })
                })

                Button() {
                    SymbolGlyph($r('sys.symbol.message')).fontSize(18)
                }
                .buttonStyle(ButtonStyleMode.NORMAL)
                .padding(6)
            }
        }
        .padding({
            top: 5,
            bottom: 5
        })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
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

@ObservedV2
export class ShareCommentObservedV2 {
    @Trace
    id: number = 0
    @Trace
    user: UserInPostObservedV2 = Object()
    @Trace
    content: string = ''
    @Trace
    createTime: string = ''
    @Trace
    likeCount: number = 0
    @Trace
    isDeleted: number = 0
    @Trace
    type = 'comment'
}

@ObservedV2
export class SharePostObservedV2 extends ShareCommentObservedV2 {
    @Trace
    type = 'post'
    @Trace
    images: string[] = []
    @Trace
    isLike: boolean = false
    @Trace
    comments_of_post: ShareCommentObservedV2[] = []
}

@ObservedV2
export class UserInPostObservedV2 {
    @Trace
    id: number
    @Trace
    nickName: string

    constructor(id: number, nickName: string) {
        this.id = id
        this.nickName = nickName
    }
}

@Builder
export function PageBuilder() {
    Page()
}