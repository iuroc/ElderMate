import { AppNavigation } from './AppNavigation'

@Entry
@Component
struct Page {
    pathInfos = new NavPathStack()

    build() {
        RelativeContainer() {
            AppNavigation({ pathInfos: this.pathInfos })
        }
    }
}