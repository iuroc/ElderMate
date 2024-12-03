import { BSColor } from '@iuroc/bootstrap5-color'

@Entry
@Component
struct Index {
    @State numsList: NumsList = new NumsList(
        new Nums(),
    )

    build() {
        Column() {
            NumLineList({
                numsList: this.numsList
            })
        }
        .width('100%')
        .height('100%')
    }
}


@Component
struct NumLineList {
    @ObjectLink numsList: NumsList

    build() {
        Column({ space: 10 }) {
            ForEach(this.numsList, (nums: Nums) => {
                NumLine({ nums: nums })
            })
            Button('All Add').onClick(() => {
                this.numsList[0].push(0)
            })
            Text(this.numsList[0].length.toString())
        }
        .width('100%')
        .height('100%')
        .padding(20)
    }
}

@Component
struct NumLine {
    @ObjectLink nums: Nums

    build() {
        Row({ space: 10 }) {
            ForEach(this.nums, (num: number) => {
                Text(num.toString())
                    .padding(10)
                    .backgroundColor(BSColor.success_bg_subtle)
            })
        }
    }
}

@Observed
class NumsList extends Array<Nums> {
}

@Observed
class Nums extends Array<number> {
}