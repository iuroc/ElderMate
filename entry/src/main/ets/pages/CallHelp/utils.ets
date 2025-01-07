import { relationalStore } from "@kit.ArkData";

export async function getRdbStore() {
    return relationalStore.getRdbStore(getContext(), {
        name: 'CallHelp',
        securityLevel: relationalStore.SecurityLevel.S1
    })
}