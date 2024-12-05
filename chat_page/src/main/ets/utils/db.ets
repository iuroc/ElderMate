import { relationalStore } from '@kit.ArkData'

export async function initTables(rdbStore: relationalStore.RdbStore) {
    await rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS "message_group" (
        "id" integer NOT NULL,
        "title" text NOT NULL,
        "craete_time" text NOT NULL,
        "model" text NOT NULL,
        PRIMARY KEY ("id")
    )`)
    await rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS "message" (
        "id" INTEGER NOT NULL,
        "role" text NOT NULL,
        "content" text NOT NULL,
        "in_request" integer NOT NULL,
        "hidden" integer NOT NULL,
        "create_time" text NOT NULL,
        "group_id" INTEGER NOT NULL,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("group_id") REFERENCES "message_group" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION
    )`)
}