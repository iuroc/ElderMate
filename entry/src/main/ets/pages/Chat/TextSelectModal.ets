import { LengthMetrics } from "@kit.ArkUI"
import { systemShareText } from "./util"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"

@Component
export struct TextSelectModal {
    @Prop text: string
    controller = new TextController()
    start: number = 0
    end: number = 0
    shareTextTitle: string = ''

    async aboutToAppear() {
        const resourceManager = getContext().resourceManager
        const resource = $r('app.string.ChatPage_TextSelectModal_text_share_title')
        this.shareTextTitle = await resourceManager.getStringValue(resource)
    }

    build() {
        Scroll() {
            Column({ space: 20 }) {
                Text(this.text, { controller: this.controller })
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
                    .buttonStyle(ButtonStyleMode.NORMAL)
                    .onClick(() => {
                        systemShareText(
                            getContext(this) as common.UIAbilityContext,
                            this.shareTextTitle,
                            this.text.slice(this.start, this.end),
                        ).catch((error: BusinessError) => {
                            AlertDialog.show({
                                message: `分享失败：${error.message}`
                            })
                        })
                    })
            }
            .padding(15)
            .width('100%')
        }
        .height('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
    }
}
