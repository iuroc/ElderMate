import { ComposeListItem } from "@kit.ArkUI"

@Builder
export function PageBuilder() {
    Page()
}

@Component
struct Page {
    @Provide persons: Person[] = []

    aboutToAppear(): void {
        for (let i = 1; i <= 100; i++) {
            this.persons.push(new Person('张三' + i, i))
        }
    }

    build() {
        Column() {
            Button('选中项目数量：' + this.getSelectedCount())
            List() {
                ForEach(this.persons, (person: Person) => {
                    PersonCard({ person: person })
                })
            }
        }
    }

    getSelectedCount() {
        return this.persons.filter(i => i.selected).length
    }
}

@Component
struct PersonCard {
    @ObjectLink person: Person
    @Consume persons: Person[]

    build() {
        ListItem() {
            ComposeListItem({ contentItem: { primaryText: this.person.name } })
                .colorBlend(this.person.selected ? Color.Red : undefined)
                .onClick(() => {
                    // 修改 @Observed Person 对象属性值，触发 PersonCard 组件更新
                    this.person.selected = !this.person.selected
                    // 重新赋值 @Consume persons 数组，触发和 persons 绑定的组件更新
                    this.persons = [...this.persons]
                })
        }
    }
}

@Observed
class Person {
    name: string
    selected: boolean = false

    constructor(name: string, age: number) {
        this.name = name
    }
}