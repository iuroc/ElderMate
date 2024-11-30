@Builder
export function PageBuilder() {
    Page()
}

@Component
struct Page {
    @State menus: MenuElement[] = []
    @State status: boolean = false

    build() {
        NavDestination() {

        }
        .hideTitleBar(true)
    }
}

class Person {
    name: string
    age: number

    constructor(name: string, age: number) {
        this.name = name
        this.age = age
    }
}