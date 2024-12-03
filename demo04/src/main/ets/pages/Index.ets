@Entry
@Component
struct Index {
    @State personBox: PersonBox = new PersonBox(new Person('hello'))
    @State name: string = this.personBox.person.name

    build() {
        Column({ space: 20 }) {
            PersonBoxComp({ person: this.personBox.person })
            Button(this.name)
                .onClick(() => {
                    this.personBox.person.name = this.personBox.person.name == 'hello' ? 'world' : 'hello'
                    this.name = this.personBox.person.name
                })
        }
        .height('100%')
        .width('100%')
        .padding({ top: 50, bottom: 50 })
    }
}

@Component
struct PersonBoxComp {
    @ObjectLink person: Person

    build() {
        Column() {
            Text(this.person.name)
        }
    }
}

class PersonBox {
    person: Person

    constructor(person: Person) {
        this.person = person
    }
}

@Observed
class Person {
    name: string

    constructor(name: string) {
        this.name = name
    }
}