import { ComposeListItem, IconType } from "@ohos.arkui.advanced.ComposeListItem"
import { LengthMetrics } from "@kit.ArkUI"

@Builder
export function PageBuilder() {
    Page()
}

@Component
struct Page {
    @State persons: Person[] = []

    aboutToAppear(): void {
        for (let i = 0; i < 5; i++) {
            this.persons.push(randomPerson())
        }
    }

    build() {
        NavDestination() {
            Flex({
                direction: FlexDirection.Column,
                space: { main: LengthMetrics.vp(10) }
            }) {
                this.ListPanel()
                this.BottomPanel()
            }
        }
        .title('测试页面')
    }

    @Builder
    ListPanel() {
        Column() {
            List() {
                ForEach(this.persons, (person: Person) => {
                    PersonCard({ person: person })
                })
            }
            .width('100%')
            .height('100%')
            .padding({
                left: 10,
                right: 10
            })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .flexGrow(1)
    }

    @Builder
    BottomPanel() {
        Row() {
            Button('随机更新')
                .width('50%')
                .onClick(() => {
                    this.persons.forEach(person => randomUpdate(person))
                })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
    }
}

@Component
struct PersonCard {
    @ObjectLink person: Person

    build() {
        ListItem() {
            ComposeListItem({
                contentItem: {
                    primaryText: this.person.name,
                    secondaryText: this.person.age + '岁',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: randomItem([
                        $r('sys.media.AI_translate'),
                        $r('sys.media.AI_pause'),
                        $r('sys.media.AI_read_aloud'),
                    ]),
                },
                operateItem: {
                    text: this.person.color.toString()
                }
            })
                .onClick(() => {
                    randomUpdate(this.person)
                })
                .colorBlend(this.person.color)
        }
    }
}

@Observed
class Person implements PersonInfo {
    name: string
    age: number
    color: ResourceColor

    constructor(info: PersonInfo)

    constructor(name: string, age: number, fontColor: ResourceColor)

    constructor(nameOrInfo: string | PersonInfo, age?: number, color?: ResourceColor) {
        if (typeof nameOrInfo == 'string') {
            this.name = nameOrInfo
            this.age = age!
            this.color = color!
        } else {
            this.name = nameOrInfo.name
            this.age = nameOrInfo.age
            this.color = nameOrInfo.color
        }
    }
}

function randomItem<T>(list: Array<T>): T {
    return list[Math.floor(Math.random() * list.length)]
}

interface PersonInfo {
    name: string
    age: number
    color: ResourceColor
}

function randomPersonInfo(): PersonInfo {
    const left = randomItem(['张三', '李四', '王五', '赵六'])
    const right = randomItem(['儿子', '女儿', '老婆', '老公'])
    const name = `${left}的${right}`
    const age = Math.floor(Math.random() * 20) + 20
    const color = randomItem([Color.Blue, Color.Green, Color.Red])
    return { name, age, color }
}

function randomPerson(): Person {
    return new Person(randomPersonInfo())
}

function randomUpdate(person: Person): void {
    const newInfo = randomPersonInfo()
    person.name = newInfo.name
    person.age = newInfo.age
    person.color = newInfo.color
}