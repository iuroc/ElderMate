import { LengthMetrics } from "@kit.ArkUI"
import { getTextShareTitle, systemShareText } from "./util"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"

@Component
export struct TextSelectModal {
    @Prop text: string
    @State private start: number = 0
    @State private end: number = 0

    build() {
        Scroll() {
            Column({ space: 20 }) {
                Text(this.text)
                    .fontSize(18)
                    .copyOption(CopyOptions.InApp)
                    .selection(this.start, this.end)
                    .lineSpacing(LengthMetrics.vp(8))
                    .letterSpacing(1)
                    .onTextSelectionChange((start, end) => {
                        this.start = start
                        this.end = end
                    })
                Button('将所选内容分享给朋友')
                    .enabled(this.text.slice(this.start, this.end).length > 0)
                    .onClick(async () => {
                        systemShareText(
                            getContext(this) as common.UIAbilityContext,
                            await getTextShareTitle(),
                            this.text.slice(this.start, this.end),
                        ).catch((error: BusinessError) => {
                            AlertDialog.show({
                                message: `分享失败：${error.message}`
                            })
                        })
                    })
            }
            .padding({
                left: 15,
                right: 15,
                top: 15,
                bottom: 30
            })
            .width('100%')
        }
        .height('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
    }
}
