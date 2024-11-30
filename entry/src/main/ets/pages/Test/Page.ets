import { ComposeListItem } from "@kit.ArkUI"

@Builder
export function PageBuilder() {
    Page()
}

@Component
struct Page {
    @State menus: MenuElement[] = []
    @State status: boolean = false
    @Provide persons: Person[] = []

    aboutToAppear(): void {
        for (let i = 1; i <= 100; i++) {
            this.persons.push(new Person('张三' + i, i))
        }
    }

    build() {
        NavDestination() {
            Column({ space: 10 }) {
                this.TopPanel()
                List() {
                    ForEach(this.persons, (person: Person) => {
                        PersonCard({ person: person })
                    })
                }
                .width('100%')
                .height(0)
                .layoutWeight(1)
                .padding({ left: 10, right: 10 })
            }
            .width('100%')
            .height('100%')
            .padding({ top: 10, bottom: 10 })
        }
    }

    @Builder
    TopPanel() {
        Row({ space: 10 }) {
            Button(this.persons.filter(i => i.selected).length.toString())
        }
    }
}

@Component
struct PersonCard {
    @ObjectLink person: Person
    @Consume persons: Person[]

    build() {
        ListItem() {
            ComposeListItem({
                contentItem: {
                    primaryText: this.person.name,
                },
                operateItem: {
                    text: this.person.age.toString()
                }
            })
                .colorBlend(this.person.selected ? Color.Red : undefined)
                .onClick(() => {
                    this.person.selected = !this.person.selected
                    this.persons = [...this.persons]
                })
        }
    }
}

@Observed
class Person {
    name: string
    age: number
    selected: boolean = false

    constructor(name: string, age: number) {
        this.name = name
        this.age = age
    }
}