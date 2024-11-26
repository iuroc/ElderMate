import { MyNavigation } from './MyNavigation'

@Entry
@Component
struct Index {
    build() {
        RelativeContainer() {
            MyNavigation()
        }
    }
}
