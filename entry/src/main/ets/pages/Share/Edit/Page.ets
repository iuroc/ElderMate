import { BSColor } from '@iuroc/bootstrap5-color'
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI'
import { ImageSelectBox } from './ImageSelectBox'
import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData'

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
                            },
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
                Text(this.deleteAreaDragEnter ? '松手即可删除' : '拖动到此处删除').fontColor(Color.White)
            }
            .padding({ top: 15, bottom: 15 })
            .width('100%')
            .backgroundColor(this.deleteAreaDragEnter ? '#a42834' : BSColor.danger)
            .alignRules({
                bottom: {
                    anchor: '__container__',
                    align: VerticalAlign.Bottom
                }
            })
            .onDrop(event => {
                const record = event.getData().getRecords()[0] as unifiedDataChannel.PlainText
                const imageIndex = parseInt(record.textContent)
                this.images.splice(imageIndex, 1)
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

@Builder
export function PageBuilder() {
    Page()
}