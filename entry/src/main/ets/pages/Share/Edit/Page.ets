import { BSColor } from "@iuroc/bootstrap5-color"
import { display, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { photoAccessHelper } from "@kit.MediaLibraryKit"

@ComponentV2
struct Page {
    @Local content: string = ''
    @Local images: string[] = []

    aboutToAppear(): void {

    }

    build() {
        NavDestination() {
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
                    ImageSelectBox({ images: this.images }).padding(15)
                }
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
        }
        .menus(this.menuItems())
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
    @Param images: string[] = []
    @Local itemHeight: number = 0
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
                        Image(image).draggable(false)
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
                photoSelectOptions.maxSelectNumber = this.maxImageCount - this.images.length
                const photoViewPicker = new photoAccessHelper.PhotoViewPicker()
                photoViewPicker.select(photoSelectOptions).then(result => {
                    this.images.push(...result.photoUris)
                })
            })
        }
    }
}

@Builder
export function PageBuilder() {
    Page()
}