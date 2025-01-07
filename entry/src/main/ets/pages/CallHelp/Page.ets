import { PhoneConfig, PhoneGroup, PhoneGroupConfig } from "./PhoneGroup"
import { PersonCalls } from "./PersonCalls"

@Builder
export function PageBuilder() {
    Page()
}

@ComponentV2
struct Page {
    build() {
        NavDestination() {
            Scroll() {
                Column({ space: 15 }) {
                    PhoneGroup(this.customPhones())
                    PersonCalls()
                }
                .padding({
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 15
                })
            }
            .height('100%')
            .width('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
        }
        .title('紧急求助')
    }

    customPhones(): PhoneGroupConfig {
        return new PhoneGroupConfig({
            header: '公共紧急号码',
            phones: [
                new PhoneConfig({
                    primaryText: '110',
                    secondaryText: '报警求助',
                    icon: $r('app.media.110'),
                    callNum: '110'
                }),
                new PhoneConfig({
                    primaryText: '119',
                    secondaryText: '消防火警',
                    icon: $r('app.media.119'),
                    callNum: '119'
                }),
                new PhoneConfig({
                    primaryText: '120',
                    secondaryText: '医疗急救',
                    icon: $r('app.media.120'),
                    callNum: '120'
                }),
            ]
        })
    }
}