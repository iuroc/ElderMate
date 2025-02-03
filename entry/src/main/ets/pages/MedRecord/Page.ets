import { SymbolGlyphModifier } from '@kit.ArkUI'
import { AddMedRecordPopResult } from './AddMedRecord/utils'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        NavDestination() {
            /**
             * 就诊时间
             * 就诊医院
             * 就诊记录
             * 就诊图片
             */
        }
        .title('我的医疗记录')
        .menus([
            {
                value: '添加记录',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
                action: () => {
                    this.pathInfos.pushPath({
                        name: 'AddMedRecord',
                        onPop: info => {
                            const result = info.result as AddMedRecordPopResult
                        }
                    })
                }
            }
        ])
    }
}

@Builder
export function PageBuilder() {
    Page()
}