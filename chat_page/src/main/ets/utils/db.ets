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

export async function copyDatabaseDir() {
    const databaseDir = getContext().databaseDir
    const documentViewPicker = new picker.DocumentViewPicker()
    const documentSaveOptions = new picker.DocumentSaveOptions()
    if (canIUse('SystemCapability.FileManagement.UserFileService.FolderSelection')) {
        documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD
    }
    const targetDirPath = (await documentViewPicker.save(documentSaveOptions))[0]
    fileIo.copyDirSync(databaseDir, new fileUri.FileUri(targetDirPath).path)
}