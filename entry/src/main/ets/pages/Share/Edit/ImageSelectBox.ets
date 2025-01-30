import { display } from "@kit.ArkUI"
import { filePreview } from "@kit.PreviewKit"
import { extname, extToMime } from "../../../common/utils"
import { unifiedDataChannel, uniformTypeDescriptor } from "@kit.ArkData"
import { BSColor } from "@iuroc/bootstrap5-color"
import { photoAccessHelper } from "@kit.MediaLibraryKit"

@ComponentV2
export struct ImageSelectBox {
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
                                    mimeType: extToMime(extname(image))[0]
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
                                const unifiedData = new unifiedDataChannel.UnifiedData()
                                const text = new unifiedDataChannel.PlainText()
                                text.textContent = index.toString()
                                unifiedData.addRecord(text)
                                event.setData(unifiedData)
                            })
                            .onDragEnd(() => {
                                this.changeShowDeleteArea(false)
                            })
                            .onDrop(event => {
                                const record = event.getData().getRecords()[0] as unifiedDataChannel.PlainText
                                const index1 = parseInt(record.textContent)
                                const index2 = index
                                const temp = this.images[index1]
                                this.images[index1] = this.images[index2]
                                this.images[index2] = temp
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
