@Entry
@Component
struct Index {
    build() {
        Column() {
            PersonList({ persons: persons })
        }
        .width('100%')
        .height('100%')
    }
}

@Component
struct PersonList {
    @ObjectLink persons: Persons
    @State btnText: string = this.getBtnText()

    build() {
        Column() {
            ForEach(this.persons, (person: Person) => {
                PersonView({ person: person })
            })
            Button(this.btnText)
                .onClick(() => {
                    this.persons.forEach(person => {
                        person.name = person.name == 'world' ? 'hello' : 'world'
                    })
                    this.btnText = this.getBtnText()
                })
        }
        .width('100%')
        .height('100%')
    }

    getBtnText() {
        return this.persons[0].name == 'hello' ? 'true' : 'false'
    }
}

@Observed
class Persons extends Array<Person> {
    constructor(persons: Person[]) {
        super(...persons)
    }
}

@Component
struct PersonView {
    @ObjectLink person: Person

    build() {
        Text(this.person.name)
    }
}

@Observed
class Person {
    name: string

    constructor(name: string) {
        this.name = name
    }
}

const persons = new Persons([
    new Person('hello'),
    new Person('world'),
])
