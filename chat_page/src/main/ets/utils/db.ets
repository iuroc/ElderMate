import { relationalStore } from '@kit.ArkData'
import { fileIo, fileUri, picker } from '@kit.CoreFileKit'

/**
 * 初始化数据表
 * @throws { BusinessError }
 * @param rdbStore
 */
export async function initTables(rdbStore: relationalStore.RdbStore) {
    await rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS "chat" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "title" TEXT NOT NULL,
        "model" TEXT NOT NULL,
        "create_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )`)
    await rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS "message" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "role" TEXT NOT NULL,
        "content" TEXT NOT NULL,
        "in_request" INTEGER NOT NULL,
        "hidden" INTEGER NOT NULL,
        "chat_id" INTEGER NOT NULL,
        "send_time" DATETIME NOT NULL,
        "create_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY ("chat_id") REFERENCES "chat" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION
    )`)
}

/** 将沙箱中的数据库目录复制到选择器选择的目录 */
export async function copyDatabaseDir() {
    const databaseDir = getContext().databaseDir
    const documentViewPicker = new picker.DocumentViewPicker()
    const documentSaveOptions = new picker.DocumentSaveOptions()
    const saveUris = await documentViewPicker.save(documentSaveOptions)
    const savePath = new fileUri.FileUri(saveUris[0]).path
    fileIo.unlinkSync(savePath)
    fileIo.mkdirSync(savePath)
    fileIo.copyDirSync(databaseDir, savePath)
    console.log('已复制到', savePath)
}

export async function getDocRootDir() {
    return 'file://docs/storage/Users/currentUser/'
}