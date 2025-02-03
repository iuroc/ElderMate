import { BSColor } from '@iuroc/bootstrap5-color'
import { CustomContentDialog, LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { ImageSelectBox } from './ImageSelectBox'
import { unifiedDataChannel } from '@kit.ArkData'
import { createShare, CreateShareResult, uploadImage } from '../utils'
import { ApiResponse } from '../../../common/types'
import { BusinessError } from '@kit.BasicServicesKit'

@ComponentV2
struct Page {
    @Local content: string = ''
    @Local images: string[] = []
    @Local showDeleteArea: boolean = false
    @Local deleteAreaDragEnter: boolean = false
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    private progressDialogId = 0

    aboutToAppear(): void {

    }

    build() {
        NavDestination() {
            RelativeContainer() {
                Scroll() {
                    Column() {
                        TextArea({
                            placeholder: '这一刻的想法...',
                            text: $$this.content
                        })
                            .defaultFocus(true)
                            .showCounter(true, { highlightBorder: false })
                            .maxLength(1000)
                            .backgroundColor(Color.Transparent)
                            .constraintSize({ minHeight: 100 })
                            .lineSpacing(LengthMetrics.vp(5))
                        ImageSelectBox({
                            images: this.images,
                            showDeleteArea: this.showDeleteArea,
                            changeShowDeleteArea: value => {
                                this.showDeleteArea = value
                            },
                        }).padding(15)
                    }
                }
                .width('100%')
                .height('100%')
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                .align(Alignment.Top)

                DragDeleteArea(this)
            }
        }
        .menus(this.menuItems())
    }

    menuItems(): NavigationMenuItem[] {
        return [
            {
                value: '发布',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
                isEnabled: this.content.trim().length > 0,
                action: () => {
                    const imageURLs: string[] = []
                    promptAction.openCustomDialog({
                        builder: () => {
                            this.ProgressDialog()
                        },
                        autoCancel: false
                    }).then(dialogId => this.progressDialogId = dialogId)
                    if (this.images.length > 0) {
                        uploadImage(this.images).then(task => {
                            task.on('complete', () => {
                                this.publish(imageURLs)
                            })
                            task.on('headerReceive', (header) => {
                                const body = JSON.parse((header as UploadResult).body) as ApiResponse<string[]>
                                imageURLs.push(body.data[0])
                            })
                        })
                    } else {
                        this.publish()
                    }
                }
            }
        ]
    }

    publish(imageURLs: string[] = []) {
        createShare({
            content: this.content.trim(),
            type: 'post',
            images: imageURLs
        }).then(result => {
            // 发布完成，返回上一页
            promptAction.closeCustomDialog(this.progressDialogId)
            this.pathInfos.pop({
                result,
                content: this.content.trim(),
                images: imageURLs
            } as ShareEditPagePopResult)
        }).catch((error: BusinessError) => {
            promptAction.closeCustomDialog(this.progressDialogId)
            AlertDialog.show({
                title: '发布失败',
                message: error.message,
                buttons: [
                    {
                        value: '稍后重试',
                        action: () => {
                        },
                        fontColor: BSColor.secondary
                    }
                ]
            })
        })
    }

    @Builder
    ProgressDialog() {
        Column() {
            CustomContentDialog({
                primaryTitle: '正在发布',
                contentBuilder: () => {
                    this.ProgressDialogContent()
                },
                buttons: [
                    {
                        value: '取消发布',
                        fontColor: BSColor.danger,
                        action: () => {
                            promptAction.closeCustomDialog(this.progressDialogId)
                            this.pathInfos.pop()
                        }
                    }
                ]
            })
        }
    }

    @Builder
    ProgressDialogContent() {
        Text('请稍等片刻，马上就好~')
    }
}

interface UploadResult {
    body: string
}

@Builder
export function PageBuilder() {
    Page()
}

export interface ShareEditPagePopResult {
    result: CreateShareResult
    content: string
    images: string[]
}

/**
 * 图片拖动到底部删除的父容器（一般是 `Component`）
 */
export interface DragDeleteAreaContainer {
    showDeleteArea: boolean
    deleteAreaDragEnter: boolean
    images: string[]
}

/**
 * 图片拖动到此处删除
 * @param config
 */
@Builder
export function DragDeleteArea(config: DragDeleteAreaContainer) {
    if (config.showDeleteArea) {
        Column() {
            Text(config.deleteAreaDragEnter ? '松手即可删除' : '拖动到此处删除').fontColor(Color.White)
        }
        .padding({ top: 15, bottom: 15 })
        .width('100%')
        .backgroundColor(config.deleteAreaDragEnter ? '#a42834' : BSColor.danger)
        .alignRules({
            bottom: {
                anchor: '__container__',
                align: VerticalAlign.Bottom
            }
        })
        .onDrop(event => {
            const record = event.getData().getRecords()[0] as unifiedDataChannel.PlainText
            const imageIndex = parseInt(record.textContent)
            config.images.splice(imageIndex, 1)
            // 这行代码的作用是，如果没有这行代码，那在将图片拖拽到删除区域后
            // 会显示【松手即可删除】，然后释放瞬间，会恢复显示【拖动到此处删除】，然后才是隐藏删除区域（拖拽的图片元素本身的拖拽结束事件）
            // 合理的效果应该是，图片拖拽到删除区域后，显示【松手即可删除】
            // 然后松手后，直接隐藏删除区域，而不是有一瞬间显示【拖动到此处删除】这样的回弹
            // 加上这行代码可以解决这个问题
            config.showDeleteArea = false
            config.deleteAreaDragEnter = false
        })
        .onDragEnter(() => {
            config.deleteAreaDragEnter = true
        })
        .onDragLeave(() => {
            config.deleteAreaDragEnter = false
        })
    }
}
