import { BSColor } from '@iuroc/bootstrap5-color'

@Entry
@Component
struct Index {
    @State lines: Items[] = []

    aboutToAppear(): void {
        for (let i = 0; i < 8; i++) {
            const items = new Items()
            for (let i = 0; i < 5; i++) {
                items.push(new Item(false))
            }
            this.lines.push(items)
        }
    }

    build() {
        Column({ space: 15 }) {
            Row({ space: 15 }) {
                this.SuccessCount()
                this.DangerCount()
                this.FullSuccess()
                this.FullDanger()
            }

            Column({ space: 10 }) {
                ForEach(this.lines, (line: Item[]) => {
                    Row({ space: 10 }) {
                        ForEach(line, (item: Item) => {
                            ItemComp({ item: item })
                        })
                    }
                })
            }
        }
        .width('100%')
        .height('100%')
        .padding(15)
    }

    @Builder
    DangerCount() {
        Button(
            this.lines.reduce((p: number, c: Items) => p + c.dangerCount(), 0).toString()
        ).backgroundColor(BSColor.danger)
    }

    @Builder
    SuccessCount() {
        Button(this.lines.flat()
            .filter(i =>!i.value)
            .length
            .toString()
        ).backgroundColor(BSColor.success)
    }

    @Builder
    FullDanger() {
        Button('Full').onClick(() => {
            this.lines.forEach(line => line.forEach(item => item.value = true))
        }).backgroundColor(BSColor.danger)
    }

    @Builder
    FullSuccess() {
        Button('Full').onClick(() => {
            this.lines.forEach(line => line.forEach(item => item.value = false))
        }).backgroundColor(BSColor.success)
    }
}

@Component
struct ItemComp {
    @ObjectLink item: Item

    build() {
        Line()
            .height(50)
            .layoutWeight(1)
            .backgroundColor(this.item.value ? BSColor.danger : BSColor.success)
            .onHover(() => {
                console.log('onHover')
                this.item.value = !this.item.value
            })
    }
}

@Observed
class Items extends Array<Item> {
    dangerCount() {
        return this.filter(item => item.value).length
    }
}

@Observed
class Item {
    value: boolean

    constructor(value: boolean) {
        this.value = value
    }
}
