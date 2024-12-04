import { BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"
import { LengthMetrics } from "@ohos.arkui.node"
import { getShareTextTitle, systemShareTextWithToast } from "../utils/utils"

@Component
export struct TextSelectModal {
    @Prop text: string
    @State start: number = 0
    @State end: number = 0
    @Consume themeColor: BSColorNameMap

    build() {
        RelativeContainer() {
            Scroll() {
                Column({ space: 20 }) {
                    this.TextView()
                }
                .padding({
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 150
                })
            }
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
            .height('100%')

            this.BottomPanel()
        }
    }

    @Builder
    TextView() {
        Text(this.text)
            .width('100%')
            .fontSize(18)
            .lineSpacing(LengthMetrics.vp(8))
            .letterSpacing(1)
            .wordBreak(WordBreak.BREAK_ALL)
            .textAlign(TextAlign.JUSTIFY)
            .copyOption(CopyOptions.InApp)
            .onTextSelectionChange((start, end) => {
                this.start = start
                this.end = end
            })
    }

    @Builder
    BottomPanel() {
        Column() {
            Button('分享给朋友', { buttonStyle: ButtonStyleMode.EMPHASIZED })
                .backgroundColor(getColorGroup(this.themeColor).main)
                .enabled(this.end - this.start > 0)
                .onClick(async () => {
                    systemShareTextWithToast(
                        await getShareTextTitle(),
                        this.text.slice(this.start, this.end)
                    )
                })
        }
        .margin({ bottom: 50 })
        .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        })
        .width('100%')
        .justifyContent(FlexAlign.Center)
    }
}