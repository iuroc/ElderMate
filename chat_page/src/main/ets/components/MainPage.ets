@Component
export struct MainPage {
    @State navTitle: string = ''

    async aboutToAppear() {
        this.navTitle = await getContext().resourceManager.getStringValue($r('app.string.chat_assistant'))
    }

    build() {
        NavDestination() {
            Text(this.navTitle).fontSize(50)
        }
        .title(this.navTitle)
    }
}