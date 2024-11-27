import { AppNavigation } from './AppNavigation'

@Entry
@Component
struct Page {
    @Provide('Index') pathInfos: NavPathStack = new NavPathStack()

    onPageShow(): void {
        if (this.pathInfos.getAllPathName().length == 0) {
            this.pathInfos.pushPath({ name: 'chat' })
        }
    }

    build() {
        RelativeContainer() {
            AppNavigation()
        }
    }
}