import { relationalStore } from '@kit.ArkData'
import { PhoneConfig, PhoneGroup, PhoneGroupConfig } from './PhoneGroup'
import { BusinessError } from '@kit.BasicServicesKit'
import { AddPersonCall } from './AddPersonCall'
import { promptAction } from '@kit.ArkUI'

@ComponentV2
export struct PersonCalls {
    @Local groupConfig: PhoneGroupConfig = new PhoneGroupConfig({
        header: '紧急联系人',
        phones: []
    })
    @Local rdb: relationalStore.RdbStore = Object()
    addDialogController: CustomDialogController = new CustomDialogController({
        builder: AddPersonCall({
            createPersonCall: (name, callNum) => {
                if (this.groupConfig.phones.find(value => value.callNum == callNum)) {
                    return promptAction.showToast({ message: '当前号码已经存在' })
                }
                this.createPersonCall(name, callNum)
                this.groupConfig.phones.push(new PhoneConfig({
                    primaryText: name,
                    secondaryText: callNum,
                    callNum,
                    icon: $r('app.media.call')
                }))
                this.addDialogController.close()
            }
        })
    })

    aboutToAppear(): void {
        // relationalStore.deleteRdbStore(getContext(), 'CallHelp')
        relationalStore.getRdbStore(getContext(), {
            name: 'CallHelp',
            securityLevel: relationalStore.SecurityLevel.S1,
        }).then(rdb => {
            this.rdb = rdb
            this.initTables().then(() => {
                this.groupConfig.phones = this.getPersonCalls()
            }).catch((error: BusinessError) => {
                console.error(error.message)
            })
        })
    }

    async initTables() {
        await this.rdb.executeSql(`CREATE TABLE IF NOT EXISTS "person_call" (
            "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            "name" TEXT NOT NULL,
            "call_num" TEXT NOT NULL UNIQUE,
            "create_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        )`)
    }

    getPersonCalls() {
        const predicates = new relationalStore.RdbPredicates('person_call')
        const resultSet = this.rdb.querySync(predicates)
        const calls: PhoneConfig[] = []
        while (resultSet.goToNextRow()) {
            const name = resultSet.getString(resultSet.getColumnIndex('name'))
            const callNum = resultSet.getString(resultSet.getColumnIndex('call_num'))
            calls.push(new PhoneConfig({
                primaryText: name,
                secondaryText: callNum,
                callNum,
                icon: $r('app.media.call')
            }))
        }
        return calls
    }

    createPersonCall(name: string, callNum: string) {
        if (!name.trim()) throw new Error('联系人姓名不能为空')
        if (!callNum.match(/^\d+$/)) throw new Error('输入的手机号码格式不正确')
        this.rdb.insertSync('person_call', {
            'name': name,
            'call_num': callNum
        })
    }

    build() {
        Column() {
            PhoneGroup({
                config: this.groupConfig,
                isPerson: true,
                addDialogController: this.addDialogController,
                rdbStore: this.rdb
            })
        }
    }
}
