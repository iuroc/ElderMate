@Component
struct Page {
    aboutToAppear(): void {

    }

    build() {
        NavDestination() {
            TextInput()
        }
    }
}

@Builder
export function PageBuilder() {
    Page()
}