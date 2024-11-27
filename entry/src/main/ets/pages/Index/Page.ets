import { AppNavigation } from './AppNavigation'

@Entry
@Component
struct Page {
    pathInfos = new NavPathStack()

    onPageShow(): void {
        if (this.pathInfos.getAllPathName().length == 0) {
            this.pathInfos.pushPath({ name: 'chat' })
        }
    }

    build() {
        RelativeContainer() {
            AppNavigation({ pathInfos: this.pathInfos })
        }
    }
}