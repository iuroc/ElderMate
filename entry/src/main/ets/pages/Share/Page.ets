import { BSColor } from "@iuroc/bootstrap5-color"
import { display, promptAction, SymbolGlyphModifier, window } from "@kit.ArkUI"
import { apiOrigin } from "../../common/config"
import {
    createShare,
    createShareResultToCommentObservedV2,
    deleteContent,
    getSharePostList,
    iSharePostToObservedV2,
    shareLike
} from "./utils"
import { filePreview } from "@kit.PreviewKit"
import { extname, extToMime } from "../../common/utils"
import { request } from "@kit.BasicServicesKit"
import { fileIo, fileUri } from "@kit.CoreFileKit"
import { getUserInfo } from "../Login/utils"

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local imageHeight: number = 0
    columCount = 3
    columGap = 5
    @Consumer() shareListReload: () => void = Object()
    @Local posts: SharePostObservedV2[] = []
    listScroller = new Scroller()
    // -------- 底部评论面板 --------
    /** 当前评论的目标帖子下标 */
    nowCommentListItemIndex = 0
    /** 对某一条评论进行评论，评论对象的用户信息
     *
     * 该属性会如果不为空，会在输入框的空提示中显示需要评论的目标用户的昵称
     */
    nowCommentParentComment: ShareCommentObservedV2 | null = null
    @Local showBottomCommentArea: boolean = false
    bottomCommentAreaInputController = new TextInputController()
    @Local bottomCommentAreaContent: string = ''
    currentUser = getUserInfo()

    aboutToDisappear(): void {
        window.getLastWindow(getContext()).then(lastWindow => {
            lastWindow.off('keyboardHeightChange', this.keyboardHeightChange)
        })
    }

    keyboardHeightChange = (height: number) => {
        if (height > 0) {
            this.listScroller.scrollToIndex(this.nowCommentListItemIndex)
        }
    }

    aboutToAppear(): void {
        window.getLastWindow(getContext()).then(lastWindow => {
            lastWindow.on('keyboardHeightChange', this.keyboardHeightChange)
        })

        const defaultDisplay = display.getDefaultDisplaySync()
        this.imageHeight = (px2vp(defaultDisplay.width) - 30 - 10 - 40
            - (this.columCount - 1) * this.columGap) / 3

        this.shareListReload = () => {
            getSharePostList(0, 120).then(list => {
                this.posts.splice(0)
                this.posts.push(...iSharePostToObservedV2(list))
            })
        }
    }

    build() {
        NavDestination() {
            RelativeContainer() {
                List({ scroller: this.listScroller }) {
                    ForEach(this.posts, (post: SharePostObservedV2, index) => {
                        ListItem() {
                            Row({ space: 10 }) {
                                this.Cover($r('app.media.daimaozixiangsuren'))
                                this.Body(post, index)
                            }
                            .alignItems(VerticalAlign.Top)
                        }
                        .padding(15)
                        .margin({
                            bottom: index == this.posts.length - 1 ? 60 : 0
                        })
                    })
                }
                .width('100%')
                .height('100%')
                .divider({
                    strokeWidth: 1
                })
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                .onTouch(() => {
                    this.bottomCommentAreaInputController.stopEditing()
                })

                this.BottomCommentArea()
            }
        }
        .menus(this.menuItems())
        .title('分享生活')
        .onWillAppear(() => {
            this.shareListReload()
        })
    }

    @Builder
    BottomCommentArea() {
        if (this.showBottomCommentArea)
        Row({ space: 10 }) {
            TextInput({
                placeholder: '评论' +
                    (this.nowCommentParentComment ? this.nowCommentParentComment.user.nickName + ': ' : ''),
                text: $$this.bottomCommentAreaContent,
                controller: this.bottomCommentAreaInputController
            }).layoutWeight(1).key('bottomCommentArea')
                .onAppear(() => {
                    this.focusComment()
                })
                .onBlur(() => {
                    this.showBottomCommentArea = false
                })
            Button('发送').onClick(() => {
                const contentTrim = this.bottomCommentAreaContent.trim()
                this.bottomCommentAreaContent = ''
                const postNowIndex = this.posts[this.nowCommentListItemIndex]
                createShare({
                    content: contentTrim,
                    type: 'comment',
                    postId: postNowIndex.id,
                    commentId: this.nowCommentParentComment?.id
                }).then(result => {
                    const comment = createShareResultToCommentObservedV2(
                        result, contentTrim,
                        this.nowCommentParentComment?.user
                    )
                    postNowIndex.comments_of_post.push(comment)
                    this.bottomCommentAreaInputController.stopEditing()
                }).catch((error: Error) => {
                    promptAction.showToast(error)
                })
            }).enabled(this.bottomCommentAreaContent.trim().length > 0)
        }
        .padding(10)
        .backgroundColor(BSColor.white)
        .alignRules({
            bottom: {
                align: VerticalAlign.Bottom,
                anchor: '__container__'
            }
        })
        .width('100%')
    }

    @Builder
    Cover(src: ResourceStr) {
        Image(src).width(40).height(40)
            .borderRadius(10)
            .flexShrink(0)
    }

    @Builder
    Body(post: SharePostObservedV2, index: number) {
        Column({ space: 10 }) {
            Text(post.user.nickName)
                .fontColor(BSColor.primary_text_emphasis)
                .fontWeight(FontWeight.Regular)
                .wordBreak(WordBreak.BREAK_ALL)
            Text(post.content)
            if (post.images.length > 0) {
                Grid() {
                    ForEach(post.images, (image: string, _index) => {
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

                // 删除按钮
                if (this.currentUser.id == post.user.id) {
                    Button() {
                        SymbolGlyph($r('sys.symbol.trash')).fontSize(18).fontColor([BSColor.danger])
                    }
                    .padding(6)
                    .buttonStyle(ButtonStyleMode.NORMAL)
                    .onClick(() => {
                        AlertDialog.show({
                            title: '删除帖子',
                            message: '确定要删除帖子吗？',
                            buttons: [
                                {
                                    value: '确定删除',
                                    fontColor: BSColor.danger,
                                    action: () => {
                                        const shareId = post.id
                                        deleteContent(shareId.toString()).then(() => {
                                            this.posts.splice(index, 1)
                                        }).catch((error: Error) => {
                                            promptAction.showToast(error)
                                        })
                                    }
                                },
                                {
                                    value: '取消',
                                    action: () => {

                                    }
                                }
                            ]
                        })
                    })
                }

                // 点赞按钮
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

                // 评论按钮
                Button() {
                    SymbolGlyph($r('sys.symbol.message')).fontSize(18)
                }
                .buttonStyle(ButtonStyleMode.NORMAL)
                .padding(6)
                .onClick(() => {
                    this.nowCommentListItemIndex = index
                    this.nowCommentParentComment = null
                    if (this.showBottomCommentArea) {
                        this.focusComment()
                    } else {
                        // 这里不需要触发聚焦，因为 TextInput 的 onAppear 会触发
                        this.showBottomCommentArea = true
                    }
                })
            }

            this.CommentArea(post, index)
        }
        .padding({
            top: 5,
            bottom: 5
        })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
    }

    /** 聚焦评论输入框，请确保在输入框完全可见时（如输入框组件的 `onAppear`）调用 */
    focusComment() {
        focusControl.requestFocus('bottomCommentArea')
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

    @Builder
    CommentArea(post: SharePostObservedV2, postIndex: number) {
        Column() {
            ForEach(post.comments_of_post, (comment: ShareCommentObservedV2, index) => {
                Text() {
                    Span(comment.user.nickName)
                        .fontWeight(FontWeight.Regular)
                        .fontColor(BSColor.primary_text_emphasis)
                    if (comment.parent_comment_user && comment.parent_comment_user.id != comment.user.id) {
                        Span('回复')
                        Span(comment.parent_comment_user.nickName)
                            .fontWeight(FontWeight.Regular)
                            .fontColor(BSColor.primary_text_emphasis)
                    }
                    Span(': ')
                    Span(comment.content)
                }
                .padding({
                    left: 10,
                    right: 10,
                    top: 7,
                    bottom: 7
                })
                .wordBreak(WordBreak.BREAK_ALL)
                .border({
                    width: { top: index == 0 ? 0 : 1 },
                    color: '#DDDDDD'
                })
                .width('100%')
                .onClick(() => {
                    this.nowCommentParentComment = comment
                    this.nowCommentListItemIndex = postIndex
                    if (this.showBottomCommentArea) {
                        this.focusComment()
                    } else {
                        this.showBottomCommentArea = true
                    }
                })
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .backgroundColor('#F7F7F7')
        .borderRadius(10)
    }
}

@ObservedV2
export class ShareContentObservedV2 {
    @Trace
    id: number = 0
    @Trace
    user: UserInPostObservedV2 = Object()
    @Trace
    content: string = ''
    @Trace
    createTime: string = ''
    /**
     * @deprecated
     */
    @Trace
    likeCount: number = 0
    /**
     * @deprecated
     */
    @Trace
    isDeleted: number = 0
}

@ObservedV2
export class ShareCommentObservedV2 extends ShareContentObservedV2 {
    @Trace
    type = 'comment'
    // @Trace
    // parent_comment_nickName?: string = ''
    @Trace
    parent_comment_user?: UserInPostObservedV2 = Object()
}

@ObservedV2
export class SharePostObservedV2 extends ShareContentObservedV2 {
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