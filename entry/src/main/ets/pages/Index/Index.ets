import { AppNavigation } from './AppNavigation'

@Entry
@Component
struct Index {
    build() {
        RelativeContainer(){
            AppNavigation()
        }
    }
}