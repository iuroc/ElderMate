import { MyTabs } from './MyTabs'

@Entry
@Component
struct Index {
    // @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
    @State navigationMenuItems: NavigationMenuItem[] = []
    @State navigationTitleMode: NavigationTitleMode = NavigationTitleMode.Free
    @State navigationTitle: string = ''

    build() {
        RelativeContainer() {
            Navigation() {
                MyTabs({
                    navigationMenuItems: this.navigationMenuItems,
                    navigationTitleMode: this.navigationTitleMode,
                    navigationTitle: this.navigationTitle
                })
            }
            .title(this.navigationTitle)
            .titleMode(this.navigationTitleMode)
            .menus(this.navigationMenuItems)
            .hideBackButton(true)
        }
    }
}
