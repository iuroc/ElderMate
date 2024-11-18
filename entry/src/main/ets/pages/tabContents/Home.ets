import { _calendarManager } from '../../entryability/EntryAbility'

@Component
export struct Home {
    async aboutToAppear() {
        console.log(JSON.stringify(_calendarManager))
    }

    build() {
        Button('这里是首页')
    }
}