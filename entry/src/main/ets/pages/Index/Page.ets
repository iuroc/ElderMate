import { AppNavigation } from './AppNavigation'

@Entry
@Component
struct Page {
    build() {
        RelativeContainer(){
            AppNavigation()
        }
    }
}