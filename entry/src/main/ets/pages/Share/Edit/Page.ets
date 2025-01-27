import { BSColor } from "@iuroc/bootstrap5-color"
import { display, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { photoAccessHelper } from "@kit.MediaLibraryKit"
import { fileUri } from "@kit.CoreFileKit"
import { filePreview } from "@kit.PreviewKit"
import { extToMime } from "../../../common/utils"
import { unifiedDataChannel } from "@kit.ArkData"

@ComponentV2
struct Page {
    @Local content: string = ''
    @Local images: string[] = []
    @Local showDeleteArea: boolean = false
    @Local deleteAreaDragEnter: boolean = false

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
                            }
                        }).padding(15)
                    }
                }
                .width('100%')
                .height('100%')
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                .align(Alignment.Top)

                this.DragDeleteArea()
            }
        }
        .menus(this.menuItems())
    }

    @Builder
    DragDeleteArea() {
        if (this.showDeleteArea) {
            Column() {
                Text('拖动到此处删除').fontColor(Color.White)
            }
            .padding({ top: 15, bottom: 15 })
            .width('100%')
            .backgroundColor(BSColor.danger)
            .alignRules({
                bottom: {
                    anchor: '__container__',
                    align: VerticalAlign.Bottom
                }
            })
            .onDrop(event => {
                // console.log((event.getData().getRecords()[0].getValue() as unifiedDataChannel.Image).imageUri)  // 报错了，下次从这里继续开发
            })
            .onDragEnter(() => {
                this.deleteAreaDragEnter = true
            })
            .onDragLeave(() => {
                this.deleteAreaDragEnter = false
            })
        }
    }

    menuItems(): NavigationMenuItem[] {
        return [
            {
                value: '发布',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
                isEnabled: this.content.trim().length > 0
            }
        ]
    }
}

@ComponentV2
struct ImageSelectBox {
    @Require @Param images: string[]
    @Local itemHeight: number = 0
    @Require @Param showDeleteArea: boolean
    @Event changeShowDeleteArea: (value: boolean) => void
    columCount = 3
    columGap = 10
    /** 最多允许的配图数量 */
    maxImageCount = 9

    aboutToAppear(): void {
        const defaultDisplay = display.getDefaultDisplaySync()
        this.itemHeight = (px2vp(defaultDisplay.width) - (this.columCount + 1) * this.columGap) / 3
    }

    build() {
        Grid() {
            ForEach(this.images, (image: string, index) => {
                GridItem() {
                    Column() {
                        Image(image)
                            .onClick(() => {
                                filePreview.openPreview(getContext(), {
                                    uri: image,
                                    title: '预览图片',
                                    mimeType: extToMime(image.substring(image.lastIndexOf('.')))[0]
                                })
                            })
                            .onPreDrag(status => {
                                if (status == PreDragStatus.READY_TO_TRIGGER_DRAG_ACTION) {
                                    this.changeShowDeleteArea(true)
                                } else if (status == PreDragStatus.PREVIEW_LANDING_STARTED) {
                                    this.changeShowDeleteArea(false)
                                }
                            })
                            .onDragStart(event => {
                                const text = new unifiedDataChannel.PlainText()
                                text.textContent = image
                                const unifiedData = new unifiedDataChannel.UnifiedData(text)
                                // event.setData(unifiedData)
                            })
                            .onDragEnd(() => {
                                this.changeShowDeleteArea(false)
                            })
                    }
                    .height(this.itemHeight)
                    .width('100%')
                    .onClick(() => {
                        this.images.splice(index, 1)
                    })
                }
            })
            if (this.images.length < this.maxImageCount) {
                this.AddBox()
            }
        }
        .columnsTemplate(new Array(this.columCount).fill('1fr').join(' '))
        .columnsGap(this.columGap)
        .rowsGap(this.columGap)
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.getUIContext().getFocusController().clearFocus()
            }
        })
    }

    @Builder
    GridItem() {

    }

    @Builder
    AddBox() {
        GridItem() {
            Column() {
                SymbolGlyph($r('sys.symbol.plus')).fontSize(40).fontColor([BSColor.secondary])
                    .fontWeight(FontWeight.Normal)
            }
            .height(this.itemHeight)
            .width('100%')
            .backgroundColor('#f7f7f7')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
                const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
                photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
                photoSelectOptions.maxSelectNumber = this.maxImageCount
                photoSelectOptions.isOriginalSupported = true
                photoSelectOptions.preselectedUris = [...this.images]
                const photoViewPicker = new photoAccessHelper.PhotoViewPicker()
                photoViewPicker.select(photoSelectOptions).then(result => {
                    if (result.photoUris.length > 0) {
                        this.images.splice(0)
                        this.images.push(...result.photoUris)
                    }
                })
            })
        }
    }
}

@Builder
export function PageBuilder() {
    Page()
}